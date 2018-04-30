//
//  ViewController.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/29.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ideaTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.ideaTableView.dataSource = self
        self.ideaTableView.delegate = self
        // ナビゲーションバーに編集ボタンを追加
        self.navigationItem.setRightBarButton(self.editButtonItem, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        // todo: CoreDataからデータをfetchする
        // CoreDataからデータをfetchしてくる
        //taskmanager.fetchTask()
        // ideaTableViewを再読み込みする
        ideaTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.ideaTableView.setEditing(editing, animated: animated)
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
                self.ideaTableView.insertRows(at: [IndexPath(row: 0, section:0)], with: UITableViewRowAnimation.right)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // セル数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // todo: テーブルのセル数を決める
        //return taskmanager.tasks.count
        return 1;
    }

    // セルの内容を決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ideaTableView.dequeueReusableCell(withIdentifier: "ideaCell", for: indexPath)

        // セルのテキストを決める
        // todo: データベースから表示するideaを取得する
        //cell.textLabel?.text = taskmanager.tasks[indexPath.row].name
        cell.textLabel?.text = "test"

        return cell
    }

    // 全セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // 編集モードのときのみ削除許可
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return tableView.isEditing ? UITableViewCellEditingStyle.delete : UITableViewCellEditingStyle.none
    }

    // セルの削除処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // todo: データベースのideaを削除する
            //taskmanager.deleteTask(indexPath.row)
        }
        // taskTableViewを再読み込みする
        ideaTableView.reloadData()
    }

    // セルをタップしたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Idea", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            // todo: データベースから編集するideaを取得する
            //textField.text = self.taskmanager.tasks[indexPath.row].name
        })

        // Editボタンを追加
        let editAction = UIAlertAction(title: "EDIT", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            // todo: ideaの内容を編集する
            //self.taskmanager.editTask((alertController.textFields?.first?.text)!, indexPath.row)
            self.ideaTableView.reloadData()
        }
        alertController.addAction(editAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // 全セルの並び替えを許可
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // セルの並び替え
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // todo: データベースのideaを並び替える
        //taskmanager.sortTask(sourceIndexPath.row, destinationIndexPath.row)
    }
}
