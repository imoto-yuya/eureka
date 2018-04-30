//
//  ViewController.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/29.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addIdeaButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Idea", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "Input Idea"
        })

        // Addボタンを追加
        let addAction = UIAlertAction(title: "ADD", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                // todo: ideaを追加する処理を追加する
                // self.taskmanager.addNewTask(textField.text!)
                // self.taskTableView.insertRows(at: [IndexPath(row: 0, section:0)], with: UITableViewRowAnimation.right)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

}

