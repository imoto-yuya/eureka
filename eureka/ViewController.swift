//
//  ViewController.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/29.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var materialTableView: UITableView!

    var eurekaButton: UIButton!
    var materialManager = MaterialManager.materialManager

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Materials"

        let radius: CGFloat = 80
        self.eurekaButton = UIButton(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
        self.eurekaButton.setImage(UIImage(named: "EurekaIcon"), for: UIControlState())
        self.eurekaButton.addTarget(self, action: #selector(transitStickyBoard), for: .touchUpInside)

        self.materialTableView.dataSource = self
        self.materialTableView.delegate = self
        // ナビゲーションバーに編集ボタンを追加
        self.navigationItem.setRightBarButton(self.editButtonItem, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        // #selectorで通知後に動く関数を指定。name:は型推論可(".UIDeviceOrientationDidChange")
        NotificationCenter.default.addObserver(self, selector: #selector(changeDirection), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        // CoreDataからデータをfetchしてくる
        materialManager.fetch()
        // taskTableViewを再読み込みする
        materialTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        updateEurekaButtonPosition()
        self.navigationController?.view.addSubview(self.eurekaButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.materialTableView.setEditing(editing, animated: animated)
    }

    // 画面遷移先のViewControllerを取得し、データを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "list2StickyBoard" {
            let vc = segue.destination as! StickyBoardViewController
            var selectedGroupID: Int16 = 1
            if materialManager.groupList.count > 0 {
                selectedGroupID = (materialManager.groupList.last?.0.advanced(by: 1))!
            }
            vc.groupID = selectedGroupID
            vc.groupName = "New"
            vc.isNew = true
        }
        self.navigationController?.view.subviews.last?.removeFromSuperview()
    }

    @IBAction func addMaterialButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add material", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "Input material of idea"
        })

        // Addボタンを追加
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                self.materialManager.addNew(textField.text!)
                self.materialTableView.insertRows(at: [IndexPath(row: 0, section:0)], with: UITableViewRowAnimation.right)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc func changeDirection(notification: NSNotification){
        updateEurekaButtonPosition()
    }

    @objc func transitStickyBoard(sender: Any) {
        performSegue(withIdentifier: "list2StickyBoard", sender: nil)
    }

    func updateEurekaButtonPosition() {
        let posX = self.view.bounds.width/2
        let posY = self.view.bounds.height - self.eurekaButton.frame.height
        self.eurekaButton.center = CGPoint(x: posX, y: posY)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // セル数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materialManager.material0List.count
    }

    // セルの内容を決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = materialTableView.dequeueReusableCell(withIdentifier: "materialCell", for: indexPath)
        cell.textLabel?.text = materialManager.material0List[indexPath.row].name
        return cell
    }

    // 全セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // 編集モードのときのみ削除許可
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        //return tableView.isEditing ? UITableViewCellEditingStyle.delete : UITableViewCellEditingStyle.none
        return UITableViewCellEditingStyle.none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // セルの削除処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            materialManager.delete(indexPath.row)
        }
        // taskTableViewを再読み込みする
        materialTableView.reloadData()
    }

    // セルをタップしたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit material", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.text = self.materialManager.material0List[indexPath.row].name
        })

        // Editボタンを追加
        let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.materialManager.rename((alertController.textFields?.first?.text)!, indexPath.row)
            self.materialTableView.reloadData()
        }
        alertController.addAction(editAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // 全セルの並び替えを許可
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // セルの並び替え
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        materialManager.sort(sourceIndexPath.row, destinationIndexPath.row)
    }
}
