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

    var ideaManager = IdeaManager.ideaManager
    var selectedGroupID: Int16 = 0
    var selectedGroupName: String = ""
    var idEditing = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        //var editButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: "editButton")
        self.navigationItem.setRightBarButton(self.editButtonItem, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        ideaManager.fetchIdea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        // 通常・編集モードの切り替え
        self.idEditing = editing
        self.stickyBoardCollectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return ideaManager.groupList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StickyBoardCollectionViewCell

        // Configure the cell
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let cellImage = UIImage(named: "Image")
        imageView.image = cellImage
        cell.name.text = ideaManager.groupList[indexPath.item].1
        cell.deleteButton.isHidden = self.isEditing ? false : true
        cell.deleteButton.tag = Int(ideaManager.groupList[indexPath.item].0)

        return cell
    }

    // cell選択時
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedGroupID = ideaManager.groupList[indexPath.item].0
        self.selectedGroupName = ideaManager.groupList[indexPath.item].1
        if self.isEditing {
            let alertController = UIAlertController(title: "Rename", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
                textField.text = self.selectedGroupName
            })

            // Renameボタンを追加
            let addAction = UIAlertAction(title: "Rename", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
                if let textField = alertController.textFields?.first {
                    self.selectedGroupName = textField.text!
                    self.ideaManager.saveIdea(self.selectedGroupID, self.selectedGroupName)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StickyBoardCollectionViewCell
                    cell.name.text = self.selectedGroupName
                    collectionView.reloadItems(at: [indexPath])
                }
            }
            alertController.addAction(addAction)

            // Cancelボタンを追加
            let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        } else {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "IdeaList", style: .plain, target: nil, action: nil)
            performSegue(withIdentifier: "toStickyBoard", sender: nil)
        }
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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

    }
    */

    @IBAction func tapDeleteButton(_ sender: UIButton) {
        self.selectedGroupID = Int16(sender.tag)
        ideaManager.deleteGroup(self.selectedGroupID, force: true)
        self.stickyBoardCollectionView.reloadData()
    }

}
