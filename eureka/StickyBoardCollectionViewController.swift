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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        ideaManager.fetchIdea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.name.text = ideaManager.groupList[indexPath.item].1

        return cell
    }

    // cell選択時
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "IdeaList", style: .plain, target: nil, action: nil)
        self.selectedGroupID = ideaManager.groupList[indexPath.item].0
        self.selectedGroupName = ideaManager.groupList[indexPath.item].1
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

}
