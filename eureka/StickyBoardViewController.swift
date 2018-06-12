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

class StickyBoardViewController: UIViewController {

    @IBOutlet weak var saveButtonItem: UIBarButtonItem!

    var materialManager = MaterialManager.materialManager
    var screenWidth: CGFloat = 0
    var screenHeight: CGFloat = 0
    var shortLength: CGFloat = 0
    var longLength: CGFloat = 0
    var sizeRatio: Float = 1
    var materialList: [Material] = []
    var groupID: Int16 = 0
    var groupName: String = ""
    var isNew: Bool = true
    var backScreen: UIView!

    var selectedStickyNoteID = 0
    var isStickyNoteEdit = false

    // タッチ開始時のUIViewのorigin
    var orgOrigin: CGPoint!
    // タッチ開始時の親ビュー上のタッチ位置
    var orgParentPoint: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.groupName

        // Screen Size の取得
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
        shortLength = screenWidth < screenHeight ? screenWidth : screenHeight
        longLength = screenWidth < screenHeight ? screenHeight : screenWidth

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsOnTap = true
        self.view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.addNewMemo)))

        materialManager.fetch()

        var needNum: Int = 8
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeRatio = 0.7
            needNum = 20
        }

        if isNew {
            self.saveButtonItem.isEnabled = true
            self.saveButtonItem.tintColor = nil
            let random = RandomizedExtraction(materialManager.material0List.count)
            let indexList = random.getIndexList(needNum)
            for index in indexList {
                let material = materialManager.copy(index)
                material.groupID = self.groupID
                material.xRatio = Float(arc4random_uniform(201))/100 - 1
                material.yRatio = Float(arc4random_uniform(201))/100 - 1
                materialList.append(material)
            }
        } else {
            self.saveButtonItem.isEnabled = false
            self.saveButtonItem.tintColor = UIColor(white: 0, alpha: 0)
            materialList = materialManager.getGroup(self.groupID)
        }

        var counter: Int16 = 0
        for material in materialList {
            material.order = counter
            let stickyView = self.createStickyNoteView(material)
            self.view.addSubview(stickyView)
            counter += 1
        }
    }

    override func viewWillLayoutSubviews() {
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
        shortLength = screenWidth < screenHeight ? screenWidth : screenHeight
        longLength = screenWidth < screenHeight ? screenHeight : screenWidth
        for subview in self.view.subviews {
            if subview != self.backScreen {
                let stickyView = subview as! StickyNote
                let material = stickyView.material!
                let stickyWidth = material.stickyWidth*Float(shortLength)*self.sizeRatio
                let stickyHeight = material.stickyHeight*Float(shortLength)*self.sizeRatio
                let stickyX: CGFloat = calculateCoordinate(Float(screenWidth), material.xRatio, stickyWidth)
                let stickyY: CGFloat = calculateCoordinate(Float(screenHeight), material.yRatio, stickyHeight)
                subview.center = CGPoint(x:stickyX, y:stickyY)
            }
        }
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil && self.isNew {
            materialManager.deleteGroup(self.groupID, force: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
            let material = self.materialList[materialList.index(where: {$0.order == (sender.view?.tag)!})!]
            let stickyWidth = material.stickyWidth*Float(shortLength)*self.sizeRatio
            let stickyHeight = material.stickyHeight*Float(shortLength)*self.sizeRatio
            material.xRatio = calculateRatio(Float(screenWidth), Float(travelPoint.x), stickyWidth)
            material.yRatio = calculateRatio(Float(screenHeight), Float(travelPoint.y), stickyHeight)
            sender.view?.center = travelPoint
            break
        default:
            break
        }
    }

    @objc func addNewMemo(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began && !self.isStickyNoteEdit{
            self.isStickyNoteEdit = true
            backScreen = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight))
            backScreen.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            self.view.addSubview(backScreen)

            self.selectedStickyNoteID = Int((self.materialList.last?.order)! + 1)
            let memo = self.materialManager.addNewMemo("Memo", self.groupID)
            memo.order = Int16(self.selectedStickyNoteID)
            let stickyWidth = memo.stickyWidth*Float(shortLength)*self.sizeRatio
            let stickyHeight = memo.stickyHeight*Float(shortLength)*self.sizeRatio
            memo.xRatio = calculateRatio(Float(self.screenWidth), Float(sender.location(in: self.view).x), stickyWidth)
            memo.yRatio = calculateRatio(Float(self.screenHeight), Float(sender.location(in: self.view).y), stickyHeight)
            self.materialList.append(memo)
            let stickyView = self.createStickyNoteView(memo)
            stickyView.tag = self.selectedStickyNoteID
            stickyView.isEditable = true
            stickyView.isSelectable = true
            stickyView.becomeFirstResponder()
            self.view.addSubview(stickyView)
        }
    }

    @objc func handleLongPressGesture(sender: UILongPressGestureRecognizer) {
        let stickyView = sender.view! as! StickyNote
        self.view.bringSubview(toFront: stickyView)
        self.selectedStickyNoteID = stickyView.tag
        let material = self.materialList[materialList.index(where: {$0.order == self.selectedStickyNoteID})!]
        if sender.state == UIGestureRecognizerState.began && !self.isStickyNoteEdit{
            let width = material.isMemo ? 240 : 160
            let menu = PopoverMenuController()
            menu.prepare(at: stickyView)
            menu.viewSize = CGSize(width: width, height: 40)
            self.present(menu, animated: true, completion: {
                var button = UIButton()
                button = menu.addItem(withTitle: "Copy")
                button.tag = (sender.view?.tag)!
                button.addTarget(self, action: #selector(self.copyStickyNote), for: .touchUpInside)
                button = menu.addItem(withTitle: "Edit")
                button.tag = (sender.view?.tag)!
                button.addTarget(self, action: #selector(self.editStickyNote), for: .touchUpInside)
                if material.isMemo {
                    button = menu.addItem(withTitle: "Delete")
                    button.tag = (sender.view?.tag)!
                    button.addTarget(self, action: #selector(self.deleteStickyNote), for: .touchUpInside)
                }
            })
        }
    }

    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        let stickyView = sender.view as! StickyNote
        self.view.bringSubview(toFront: stickyView)
    }

    @objc func copyStickyNote(_ sender: UIButton) {
        UIPasteboard.general.string = self.materialList[materialList.index(where: {$0.order == sender.tag})!].name
    }

    @objc func editStickyNote(_ sender: UIButton) {
        self.isStickyNoteEdit = true
        backScreen = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight))
        backScreen.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.view.addSubview(backScreen)
        let stickyView = self.view.subviews[self.view.subviews.index(where: {$0.tag == sender.tag})!] as! StickyNote
        self.view.bringSubview(toFront: stickyView)
        stickyView.isEditable = true
        stickyView.isSelectable = true
        stickyView.becomeFirstResponder()
    }

    @objc func commitButtonTapped (){
        self.isStickyNoteEdit = false
        let stickyView = self.findFirstResponder()
        materialManager.rename(stickyView.text, stickyView.material.id!)
        self.view.endEditing(true)
        stickyView.isEditable = false
        stickyView.isSelectable = false
        self.backScreen.removeFromSuperview()
        let material = stickyView.material
        material?.xRatio = calculateRatio(Float(self.screenWidth), Float(stickyView.center.x), Float(stickyView.frame.size.width))
        material?.yRatio = calculateRatio(Float(self.screenHeight), Float(stickyView.center.y), Float(stickyView.frame.size.height))
    }

    @objc func deleteStickyNote(_ sender: UIButton) {
        let stickyView = self.view.subviews[self.view.subviews.index(where: {$0.tag == sender.tag})!] as! StickyNote
        stickyView.isEditable = false
        stickyView.isSelectable = false
        let alertController = UIAlertController(title: "Delete memo", message: "", preferredStyle: UIAlertControllerStyle.alert)

        // Deleteボタンを追加
        let addAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            let index = self.materialList.index(of: stickyView.material)!
            stickyView.removeFromSuperview()
            self.materialManager.delete(self.materialList[index].id!)
            self.materialList.remove(at: index)
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func calculateCoordinate(_ screenLength: Float, _ ratio: Float, _ stickyLength: Float) -> CGFloat {
        return CGFloat((screenLength - stickyLength)/2*ratio + screenLength/2)
    }

    func calculateRatio(_ screenLength: Float, _ travelLength: Float, _ stickyLength: Float) -> Float {
        return 2*(travelLength - screenLength/2)/(screenLength - stickyLength)
    }

    func createStickyNoteView(_ material: Material) -> UITextView {
        let stickyWidth: CGFloat = CGFloat(material.stickyWidth*self.sizeRatio)*self.shortLength
        let stickyHeight:CGFloat = CGFloat(material.stickyHeight*self.sizeRatio)*self.shortLength
        let stickyView = material.isMemo ? StickyNote(frame: CGRect(x:0, y:0, width:stickyWidth, height:stickyHeight), material: material, width: stickyWidth, height: stickyHeight) : StickyNote(frame: CGRect(x:0, y:0, width:stickyWidth, height:stickyHeight), material: material)
        stickyView.tag = Int(material.order)

        let stickyX: CGFloat = self.calculateCoordinate(Float(self.screenWidth), material.xRatio, Float(stickyWidth))
        let stickyY: CGFloat = self.calculateCoordinate(Float(self.screenHeight), material.yRatio, Float(stickyHeight))
        stickyView.center = CGPoint(x: stickyX, y: stickyY)
        stickyView.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(self.handlePanGesture)))
        stickyView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture)))
        stickyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture)))

        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // スタイルを設定
        kbToolBar.barStyle = UIBarStyle.default
        // 画面幅に合わせてサイズを変更
        kbToolBar.sizeToFit()
        // スペーサ
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(StickyBoardViewController.commitButtonTapped))
        kbToolBar.items = [spacer, commitButton]
        stickyView.inputAccessoryView = kbToolBar

        return stickyView
    }

    func findFirstResponder() -> StickyNote {
        var stickyView: StickyNote!
        for view in self.view.subviews {
            if view.isFirstResponder {
                stickyView = view as! StickyNote
            }
        }
        return stickyView
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
                self.materialManager.save(self.groupID, self.groupName)
                self.navigationItem.title = self.groupName
                self.isNew = false
                self.saveButtonItem.isEnabled = false
                self.saveButtonItem.tintColor = UIColor(white: 0, alpha: 0)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func addMemoButton(_ sender: UIBarButtonItem) {
    }
}
