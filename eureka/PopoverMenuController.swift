//
//  PopoverMenuController.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/05/30.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class PopoverMenuController: UIViewController, UIPopoverPresentationControllerDelegate {

    private var stackView:UIStackView! = nil
    var viewSize: CGSize = CGSize()
    var axis: UILayoutConstraintAxis = .horizontal
    var isVisible: Bool {
        get {
            return self.view.window != nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.viewSize.width, height: self.viewSize.height))
        self.stackView.backgroundColor = UIColor.white
        self.stackView.axis = self.axis
        self.stackView.distribution = .fillEqually
        self.view.addSubview(self.stackView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredContentSize: CGSize {
        get {
            return CGSize(width:self.viewSize.width, height:self.viewSize.height)
        }
        set {
            print("Cannot set preferredContentSize of this view controller.")
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepare(at view: UIView) {
        self.modalPresentationStyle = .popover
        if let popover = self.popoverPresentationController {
            popover.permittedArrowDirections = .any
            popover.sourceView = view
            popover.sourceRect = view.bounds
            popover.delegate = self
        }
    }

    func addItem(withTitle: String)->UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        button.setTitle(withTitle, for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0), for: .normal)
        button.addTarget(self, action: #selector(dismissPopover), for: .touchUpInside)
        self.stackView.addArrangedSubview(button)
        return button
    }

    @objc func dismissPopover() {
        self.dismiss(animated: false)
    }
}
