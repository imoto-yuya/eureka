//
//  StickBoardCollectionViewController.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/05/19.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

private let reuseIdentifier = "stickyBoard"

class StickyBoardCollectionViewController: UICollectionViewController {

    @IBOutlet weak var stickyBoardCollectionView: UICollectionView!

    var materialManager = MaterialManager.materialManager
    var selectedGroupID: Int16 = 0
    var selectedGroupName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Collections"
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        materialManager.fetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return materialManager.groupList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.stickyBoardCollectionView.backgroundColor = UIColor(red: 0.906, green: 0.906, blue: 0.886, alpha: 1.0)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StickyBoardCollectionViewCell

        // Configure the cell
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let cellImage = UIImage(named: "Image")
        imageView.image = cellImage
        let groupID = Int(materialManager.groupList[indexPath.item].0)
        let groupName = materialManager.groupList[indexPath.item].1
        cell.nameButton.isEnabled = false
        cell.nameButton.setTitle(groupName, for: UIControlState.normal)
        cell.nameButton.tag = groupID
        cell.tag = groupID
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture)))

        return cell
    }

    // cell選択時
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedGroupID = materialManager.groupList[indexPath.item].0
        self.selectedGroupName = materialManager.groupList[indexPath.item].1
        performSegue(withIdentifier: "toStickyBoard", sender: nil)
    }

    // 画面遷移先のViewControllerを取得し、データを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStickyBoard" {
            let vc = segue.destination as! StickyBoardViewController
            vc.groupID = self.selectedGroupID
            vc.groupName = self.selectedGroupName
            vc.isNew = false
        }
    }

    @objc func handleLongPressGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let menu = PopoverMenuController()
            menu.prepare(at: sender.view!)
            menu.viewSize = CGSize(width: 160, height: 40)
            self.present(menu, animated: true, completion: {
                var button = UIButton()
                button = menu.addItem(withTitle: "Rename")
                button.tag = (sender.view?.tag)!
                button.addTarget(self, action: #selector(self.renameGroup), for: .touchUpInside)
                button = menu.addItem(withTitle: "Delete")
                button.tag = (sender.view?.tag)!
                button.addTarget(self, action: #selector(self.deleteGroup), for: .touchUpInside)
            })
        }
    }

    @objc func deleteGroup(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Delete group", message: "", preferredStyle: UIAlertControllerStyle.alert)

        // Deleteボタンを追加
        let addAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.selectedGroupID = Int16(sender.tag)
            self.materialManager.deleteGroup(self.selectedGroupID, force: true)
            self.stickyBoardCollectionView.reloadData()
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc func renameGroup(_ sender: UIButton) {
        let groupID = sender.tag
        let groupName = materialManager.groupList[materialManager.groupList.index(where: {$0.0 == groupID})!].1
        let alertController = UIAlertController(title: "Rename", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.text = groupName
        })

        // Renameボタンを追加
        let addAction = UIAlertAction(title: "Rename", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                let name = textField.text!
                self.materialManager.save(Int16(groupID), name)
                let cell = self.collectionView?.visibleCells[(self.collectionView?.visibleCells.index(where: {$0.tag == groupID})!)!]  as! StickyBoardCollectionViewCell
                cell.nameButton.setTitle(name, for: UIControlState.normal)
            }
        }
        alertController.addAction(addAction)

        // Cancelボタンを追加
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
