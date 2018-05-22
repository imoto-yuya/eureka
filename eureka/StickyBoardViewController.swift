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

        let rootViewController = self.navigationController?.viewControllers.first
        self.navigationController?.setViewControllers([rootViewController!, self], animated:true)
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
            let random = RandomizedExtraction(ideaManager.ideas.count)
            let indexList = random.getIndexList(needNum)
            for index in indexList {
                let idea = ideaManager.copyIdea(index)
                idea.groupID = self.groupID
                tempIdea.append(idea)
            }
        } else {
            tempIdea = ideaManager.getGroup(self.groupID)
        }

        for idea in tempIdea {
            let stickyWidth: CGFloat = CGFloat(idea.stickyWidth*sizeRatio)
            let stickyHeight: CGFloat = CGFloat(idea.stickyHeight*sizeRatio)
            let stickyView = DrawSticky(frame: CGRect(x:0, y:0, width:stickyWidth, height:stickyHeight), idea: idea)
            stickyView.tag = tempIdea.index(of: idea)!

            let stickyX: CGFloat = calculateCoordinate(Float(screenWidth), idea.xRatio, Float(stickyWidth))
            let stickyY: CGFloat = calculateCoordinate(Float(screenHeight), idea.yRatio, Float(stickyHeight))
            stickyView.center = CGPoint(x: stickyX, y: stickyY)
            stickyView.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(handlePanGesture)))
            self.view.addSubview(stickyView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
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

    func calculateCoordinate(_ screenLength: Float, _ ratio: Float, _ stickyLength: Float) -> CGFloat {
        return CGFloat((screenLength - stickyLength)/2*ratio + screenLength/2)
    }

    func calculateRatio(_ screenLength: Float, _ travelLength: Float, _ stickyLength: Float) -> Float {
        return 2*(travelLength - screenLength/2)/(screenLength - stickyLength)
    }

    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        ideaManager.saveIdea(groupID, "idea" + groupID.description)
    }
}
