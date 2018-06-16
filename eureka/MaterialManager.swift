//
//  MaterialManager.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/30.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MaterialManager {
    static let materialManager = MaterialManager()
    private init() {}

    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var material0List: [Material] = []
    var materialList: [Material] = []
    var groupList: [(Int16, String)] = []

    func fetch() {
        let fetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupID = 0")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            self.material0List = []
            self.material0List = try context.fetch(fetchRequest)
        } catch {
            print("Fetching Failed")
        }

        let allfetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
        allfetchRequest.sortDescriptors = [NSSortDescriptor(key: "groupID", ascending: true)]
        do {
            self.materialList = []
            self.materialList = try context.fetch(allfetchRequest)
        } catch {
            print("Fetching Failed")
        }
        var tempGroupID: Int16 = 0
        groupList = []
        for material in self.materialList {
            if material.groupID != tempGroupID && material.isSave {
                groupList.append((material.groupID, material.groupName!))
                tempGroupID = material.groupID
            }
            // todo: 二分探索にする
            // todo: 別メソッドにする. 付箋ボードビューでのみ名前の同期が必要
            if material.groupID > 0 {
                for material0 in self.material0List {
                    if material.id == material0.id {
                        material.name = material0.name
                    }
                }
            }
        }
    }

    func updateOrder() {
        var order: Int16 = 0
        for material in material0List {
            material.order = order
            order += 1
        }
    }

    func copy(_ index: Int) -> Material {
        let material = Material(context: context)
        material.id = material0List[index].id
        material.groupID = material0List[index].groupID
        material.isSave = material0List[index].isSave
        material.name = material0List[index].name
        material.order = material0List[index].order
        material.xRatio = material0List[index].xRatio
        material.yRatio = material0List[index].yRatio
        material.stickyFontSize = material0List[index].stickyFontSize
        material.stickyWidth = material0List[index].stickyWidth
        material.stickyHeight = material0List[index].stickyHeight
        material.stickyRGBRed = material0List[index].stickyRGBRed
        material.stickyRGBGreen = material0List[index].stickyRGBGreen
        material.stickyRGBBlue = material0List[index].stickyRGBBlue
        material.stickyRGBAlpha = material0List[index].stickyRGBAlpha
        materialList.append(material)
        return material
    }

    func insert(_ material: Material, _ insertIndex: Int) {
        material0List.insert(material, at: insertIndex)
        materialList.append(material)
        updateOrder()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func delete(_ index: Int) {
        context.delete(material0List[index])
        material0List.remove(at: index)
        updateOrder()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func addNew(_ name: String) {
        let material = Material(context: context)
        material.id = NSUUID() as UUID
        material.groupID = 0
        material.isSave = false
        material.isMemo = false
        material.name = name
        material.xRatio = 0
        material.yRatio = 0
        material.stickyFontSize = 16
        material.stickyWidth = 0.35
        material.stickyHeight = 0.26
        material.stickyRGBRed = 1.0
        material.stickyRGBGreen = 0.937
        material.stickyRGBBlue = 0.522
        material.stickyRGBAlpha = 1.0
        insert(material, 0)
    }

    func rename(_ name: String, _ index: Int) {
        self.material0List[index].name = name
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func rename(_ name: String, _ uuid: UUID) {
        for material in self.materialList.filter({$0.id == uuid}) {
            material.name = name
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func delete(_ material: Material) {
        self.materialList.remove(at: self.materialList.index(of: material)!)
        context.delete(material)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func sort(_ sourceIndexPath: Int, _ destinationIndexPath: Int) {
        let material = copy(sourceIndexPath)
        delete(sourceIndexPath)
        insert(material, destinationIndexPath)
    }

    func addNewMemo(_ contents: String, _ groupID: Int16) -> Material {
        let material = Material(context: context)
        material.id = NSUUID() as UUID
        material.groupID = groupID
        material.isSave = false
        material.isMemo = true
        material.name = contents
        material.xRatio = 0
        material.yRatio = 0
        material.stickyFontSize = 16
        material.stickyWidth = 0.8
        material.stickyHeight = 0.3
        material.stickyRGBRed = 0
        material.stickyRGBGreen = 0
        material.stickyRGBBlue = 0
        material.stickyRGBAlpha = 0
        self.materialList.append(material)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        return material
    }

    func save(_ groupID: Int16, _ groupName: String) {
        for material in self.materialList {
            if material.groupID == groupID {
                material.groupName = groupName
                material.isSave = true
                if let index = self.groupList.index(where: {$0.0 == groupID}) {
                    self.groupList[index].1 = groupName
                } else {
                    self.groupList.append((material.groupID, material.groupName!))
                }
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func deleteGroup(_ groupID: Int16, force: Bool) {
        for material in self.materialList {
            let isDelete = force ? true : !material.isSave
            if material.groupID == groupID && isDelete {
                context.delete(material)
                if let index = self.groupList.index(where: {$0.0 == groupID}) {
                    self.groupList.remove(at: index)
                }
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func getGroup(_ groupID: Int16) -> [Material]{
        var materialList: [Material] = []
        for material in self.materialList {
            if material.groupID == groupID {
                materialList.append(material)
            }
        }
        return materialList
    }
}
