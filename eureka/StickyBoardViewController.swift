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

    // タッチ開始時のUIViewのorigin
    var orgOrigin: CGPoint!
    // タッチ開始時の親ビュー上のタッチ位置
    var orgParentPoint: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Screen Size の取得
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height

        let sizeRatio: Float = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 1.5

        for idea in ideaManager.ideas.reversed() {
            let stickyX: CGFloat = CGFloat(idea.xRatio)*screenWidth
            let stickyY: CGFloat = CGFloat(idea.yRatio)*screenHeight
            let stickyWidth: CGFloat = CGFloat(idea.stickyWidth*sizeRatio)
            let stickyHeight: CGFloat = CGFloat(idea.stickyHeight*sizeRatio)
            let stickyView = DrawSticky(frame: CGRect(x:stickyX, y:stickyY, width:stickyWidth, height:stickyHeight), idea: idea)
            stickyView.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(handlePanGesture)))
            self.view.addSubview(stickyView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // #selectorで通知後に動く関数を指定。name:は型推論可(".UIDeviceOrientationDidChange")
        NotificationCenter.default.addObserver(self, selector: #selector(changeDirection), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
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
            orgOrigin = sender.view?.frame.origin
            orgParentPoint = sender.translation(in: self.view)
            break
        case UIGestureRecognizerState.changed:
            // 現在の親ビュー上でのタッチ位置を求める
            let newParentPoint = sender.translation(in: self.view)
            // パンジャスチャの継続:タッチ開始時のビューのoriginにタッチ開始からの移動量を加算する
            let travelPoint = orgOrigin + newParentPoint - orgParentPoint
            ideaManager.ideas[(sender.view?.tag)!].xRatio = Float(travelPoint.x / screenWidth)
            ideaManager.ideas[(sender.view?.tag)!].yRatio = Float(travelPoint.y / screenHeight)
            sender.view?.frame.origin = travelPoint
            break
        default:
            break
        }
    }

    @objc func changeDirection(notification: NSNotification){
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
        for subview in self.view.subviews {
            let idea = ideaManager.ideas[subview.tag]
            let stickyX: CGFloat = CGFloat(idea.xRatio)*screenWidth
            let stickyY: CGFloat = CGFloat(idea.yRatio)*screenHeight
            subview.frame.origin = CGPoint(x:stickyX, y:stickyY)
        }
    }
}
