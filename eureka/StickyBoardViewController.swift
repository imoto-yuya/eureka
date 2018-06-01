//
//  StickyBoardViewController.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/30.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

// ユーティリティメソッド CGPoint同士の足し算を+で書けるようにする
func -(_ left:CGPoint, _ right:CGPoint)->CGPoint{
    return CGPoint(x:left.x - right.x, y:left.y - right.y)
}
// ユーティリティメソッド CGPoint同士の引き算を-で書けるようにする
func +(_ left:CGPoint, _ right:CGPoint)->CGPoint{
    return CGPoint(x:left.x + right.x, y:left.y + right.y)
}

extension UIView {
    func find(_ tag: Int) -> UIView {
        var returnView = UIView()

        for subview in self.subviews {
            if subview.tag == tag {
                returnView = subview
            }
        }
        return returnView
    }
}

class StickyBoardViewController: UIViewController {

    @IBOutlet weak var saveButtonItem: UIBarButtonItem!

    var ideaManager = IdeaManager.ideaManager
    var screenWidth: CGFloat = 0
    var screenHeight: CGFloat = 0
    var sizeRatio: Float = 1
    var tempIdea: [Idea] = []
    var groupID: Int16 = 0
    var groupName: String = ""
    var isNew: Bool = true

    // タッチ開始時のUIViewのorigin
    var orgOrigin: CGPoint!
    // タッチ開始時の親ビュー上のタッチ位置
    var orgParentPoint: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()

        //let rootViewController = self.navigationController?.viewControllers.first
        //self.navigationController?.setViewControllers([rootViewController!, self], animated:true)
        self.navigationItem.title = self.groupName

        // Do any additional setup after loading the view.
        ideaManager.fetchIdea()
        // Screen Size の取得
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height

        var needNum: Int = 8
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeRatio = 1.5
            needNum = 20
        }

        if isNew {
            self.saveButtonItem.isEnabled = true
            self.saveButtonItem.tintColor = nil
            let random = RandomizedExtraction(ideaManager.ideas.count)
            let indexList = random.getIndexList(needNum)
            for index in indexList {
                let idea = ideaManager.copyIdea(index)
                idea.groupID = self.groupID
                idea.xRatio = Float(arc4random_uniform(201))/100 - 1
                idea.yRatio = Float(arc4random_uniform(201))/100 - 1
                tempIdea.append(idea)
            }
        } else {
            self.saveButtonItem.isEnabled = false
            self.saveButtonItem.tintColor = UIColor(white: 0, alpha: 0)
            tempIdea = ideaManager.getGroup(self.groupID)
        }

        for idea in tempIdea {
            self.addStickyNoteToView(idea)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsOnTap = true
        // #selectorで通知後に動く関数を指定。name:は型推論可(".UIDeviceOrientationDidChange")
        NotificationCenter.default.addObserver(self, selector: #selector(changeDirection), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        ideaManager.fetchIdea()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil && self.isNew{
            ideaManager.deleteGroup(self.groupID, force: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // Viewのパンジェスチャーに反応し、処理するためのメソッド
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        self.view.bringSubview(toFront: sender.view!)
        switch sender.state {
        case UIGestureRecognizerState.began:
            // タッチ開始:タッチされたビューのoriginと親ビュー上のタッチ位置を記録しておく
            orgOrigin = sender.view?.center
            orgParentPoint = sender.translation(in: self.view)
            break
        case UIGestureRecognizerState.changed:
            // 現在の親ビュー上でのタッチ位置を求める
            let newParentPoint = sender.translation(in: self.view)
            // パンジャスチャの継続:タッチ開始時のビューのoriginにタッチ開始からの移動量を加算する
            let travelPoint = orgOrigin + newParentPoint - orgParentPoint
            let idea = tempIdea[(sender.view?.tag)!]
            idea.xRatio = calculateRatio(Float(screenWidth), Float(travelPoint.x), idea.stickyWidth*sizeRatio)
            idea.yRatio = calculateRatio(Float(screenHeight), Float(travelPoint.y), idea.stickyHeight*sizeRatio)
            sender.view?.center = travelPoint
            break
        default:
            break
        }
    }

    @objc func handleLongPressGesture(sender: UILongPressGestureRecognizer) {
        self.view.bringSubview(toFront: sender.view!)
        if sender.state == UIGestureRecognizerState.began {
            let idea = self.tempIdea[(sender.view?.tag)!]
            let isMemo = idea.isMemo
            let width = isMemo ? 240 : 160
            let menu = PopoverMenuController()
            menu.prepare(at: sender.view!)
            menu.viewSize = CGSize(width: width, height: 40)
            self.present(menu, animated: true, completion: {
                var button = UIButton()
                button = menu.addItem(withTitle: "Copy")
                button.tag = (sender.view?.tag)!
                button.addTarget(self, action: #selector(self.copyStickyNote), for: .touchUpInside)
                button = menu.addItem(withTitle: "Edit")
                button.tag = (sender.view?.tag)!
                button.addTarget(self, action: #selector(self.editStickyNote), for: .touchUpInside)
                if isMemo {
                    button = menu.addItem(withTitle: "Delete")
                    button.tag = (sender.view?.tag)!
                    button.addTarget(self, action: #selector(self.deleteStickyNote), for: .touchUpInside)
                }
            })
        }
    }

    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        self.view.bringSubview(toFront: sender.view!)
    }

    @objc func changeDirection(notification: NSNotification){
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
        for subview in self.view.subviews {
            let idea = tempIdea[subview.tag]
            let stickyX: CGFloat = calculateCoordinate(Float(screenWidth), idea.xRatio, idea.stickyWidth*sizeRatio)
            let stickyY: CGFloat = calculateCoordinate(Float(screenHeight), idea.yRatio, idea.stickyHeight*sizeRatio)
            subview.center = CGPoint(x:stickyX, y:stickyY)
        }
    }

    @objc func copyStickyNote(_ sender: UIButton) {
        UIPasteboard.general.string = self.tempIdea[sender.tag].name
    }

    @objc func editStickyNote(_ sender: UIButton) {
        let idea = self.tempIdea[sender.tag]

        let alertController = UIAlertController(title: "Edit", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.text = idea.name
        })

        // Editボタンを追加
        let addAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                idea.name = textField.text!
                self.ideaManager.editIdea(idea.name!, idea.id!)
                self.view.find(sender.tag).removeFromSuperview()
                self.addStickyNoteToView(idea)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc func deleteStickyNote(_ sender: UIButton) {
        self.tempIdea.remove(at: sender.tag)
        self.view.find(sender.tag).removeFromSuperview()
    }

    func calculateCoordinate(_ screenLength: Float, _ ratio: Float, _ stickyLength: Float) -> CGFloat {
        return CGFloat((screenLength - stickyLength)/2*ratio + screenLength/2)
    }

    func calculateRatio(_ screenLength: Float, _ travelLength: Float, _ stickyLength: Float) -> Float {
        return 2*(travelLength - screenLength/2)/(screenLength - stickyLength)
    }

    func addStickyNoteToView(_ idea: Idea) {
        let stickyWidth: CGFloat = CGFloat(idea.stickyWidth*self.sizeRatio)
        let stickyHeight: CGFloat = CGFloat(idea.stickyHeight*self.sizeRatio)
        let stickyView = DrawSticky(frame: CGRect(x:0, y:0, width:stickyWidth, height:stickyHeight), idea: idea)
        stickyView.tag = self.tempIdea.index(of: idea)!

        let stickyX: CGFloat = self.calculateCoordinate(Float(self.screenWidth), idea.xRatio, Float(stickyWidth))
        let stickyY: CGFloat = self.calculateCoordinate(Float(self.screenHeight), idea.yRatio, Float(stickyHeight))
        stickyView.center = CGPoint(x: stickyX, y: stickyY)
        stickyView.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(self.handlePanGesture)))
        stickyView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture)))
        stickyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture)))
        self.view.addSubview(stickyView)
    }

    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Save", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "Input name"
        })

        // Saveボタンを追加
        let addAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                self.groupName = textField .text!
                self.ideaManager.saveIdea(self.groupID, self.groupName)
                self.navigationItem.title = self.groupName
                self.isNew = false
                self.saveButtonItem.isEnabled = false
                self.saveButtonItem.tintColor = UIColor(white: 0, alpha: 0)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func addMemoButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add memo", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "Input memo"
        })

        // Addボタンを追加
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                let idea = self.ideaManager.addNewMemo(textField.text!, self.groupID)
                self.tempIdea.append(idea)
                self.addStickyNoteToView(idea)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
