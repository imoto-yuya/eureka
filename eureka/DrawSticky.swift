//
//  DrawSticky.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/30.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class DrawSticky: UIView {
    var idea: Idea!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func draw(_ rect: CGRect) {
        idea.name?.draw(at: CGPoint(x: 0, y: 0), withAttributes: [NSAttributedStringKey.foregroundColor : UIColor.black, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24),])
    }

}
