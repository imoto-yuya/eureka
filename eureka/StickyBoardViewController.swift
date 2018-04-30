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

        let fontSize: CGFloat!
        let stickyWidth: CGFloat!
        let stickyHeight: CGFloat!
        if UIDevice.current.userInterfaceIdiom == .phone {
            fontSize = 12
            stickyWidth = 100
            stickyHeight = 80
        } else {
            fontSize = 20
            stickyWidth = 180
            stickyHeight = 140
        }

        for idea in ideaManager.ideas.reversed() {
            let stickyView = DrawSticky(frame: CGRect(x:CGFloat(idea.xRatio)*screenWidth, y:CGFloat(idea.yRatio)*screenHeight, width:stickyWidth, height:stickyHeight))
            stickyView.idea = idea
            stickyView.fontSize = fontSize
            stickyView.backgroundColor = UIColor(red: 1.0, green: 0.937, blue: 0.522, alpha: 1.0)
            stickyView.layer.borderWidth = 2.0
            stickyView.layer.borderColor = UIColor.white.cgColor
            stickyView.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(handlePanGesture)))
            stickyView.tag = Int(idea.order)
            self.view.addSubview(stickyView)
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
            orgOrigin = sender.view?.frame.origin
            orgParentPoint = sender.translation(in: self.view)
            break
        case UIGestureRecognizerState.changed:
            // 現在の親ビュー上でのタッチ位置を求める
            let newParentPoint = sender.translation(in: self.view)
            // パンジャスチャの継続:タッチ開始時のビューのoriginにタッチ開始からの移動量を加算する
            let travelPoint = orgOrigin + newParentPoint - orgParentPoint
            ideaManager.ideas[(sender.view?.tag)!].xRatio = Float(travelPoint.x / screenWidth)
            ideaManager.ideas[(sender.view?.tag)!].yRatio = Float(travelPoint.y / screenWidth)
            sender.view?.frame.origin = travelPoint
            break
        default:
            break
        }
    }
}
