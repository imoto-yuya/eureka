//
//  DrawSticky.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/30.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class DrawSticky: UITextView {
    var idea: Idea!

    // 入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }

    // 範囲選択カーソル非表示
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }

    // コピー・ペースト・選択等のメニュー非表示
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, idea: Idea) {
        super.init(frame: frame, textContainer: nil)
        self.idea = idea
        initialize()
    }

    func initialize() {
        let sizeRatio: Float = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 1.5
        self.text = idea.name
        self.font = UIFont.systemFont(ofSize: CGFloat(idea.stickyFontSize*sizeRatio))
        self.backgroundColor = UIColor(red: CGFloat(idea.stickyRGBRed), green: CGFloat(idea.stickyRGBGreen), blue: CGFloat(idea.stickyRGBBlue), alpha: 1.0)
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.white.cgColor
        self.isEditable = false
    }

}