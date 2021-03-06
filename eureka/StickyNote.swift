//
//  DrawSticky.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/30.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class StickyNote: UITextView, UITextViewDelegate {

    var material: Material!
    var maxSize = CGSize(width: 9999, height: 9999)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, material: Material) {
        super.init(frame: frame, textContainer: nil)
        self.delegate = self
        self.material = material
        initialize()
    }

    init(frame: CGRect, material: Material, width: CGFloat, height: CGFloat) {
        maxSize = CGSize(width: width, height: height)
        super.init(frame: frame, textContainer: nil)
        self.delegate = self
        self.material = material
        initialize()
    }

    func initialize() {
        let sizeRatio: Float = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 1.5
        self.text = material.name
        self.font = UIFont.systemFont(ofSize: CGFloat(material.stickyFontSize*sizeRatio))
        self.backgroundColor = UIColor(red: CGFloat(material.stickyRGBRed), green: CGFloat(material.stickyRGBGreen), blue: CGFloat(material.stickyRGBBlue), alpha: CGFloat(material.stickyRGBAlpha))
        self.isEditable = false
        self.isSelectable = false
        if material.isMemo {
            self.frame.size = maxSize
            let size: CGSize = self.sizeThatFits(self.frame.size)
            self.frame.size.width = size.width
            self.frame.size.height = size.height
        } else {
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.white.cgColor
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if material.isMemo {
            self.frame.size = maxSize
            self.frame.size.height = CGFloat(material.stickyHeight)
            let size: CGSize = self.sizeThatFits(self.frame.size)
            self.frame.size.width = size.width
            self.frame.size.height = size.height
        }
    }

}
