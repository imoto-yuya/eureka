//
//  IdeaManager.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/04/30.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class IdeaManager {
    static let ideaManager = IdeaManager()
    private init() {}

    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var ideas: [Idea] = []
    var allIdeaList: [Idea] = []
    var groupList: [(Int16, String)] = []

    func fetchIdea() {
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupID = 0")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            ideas = []
            ideas = try context.fetch(fetchRequest)
        } catch {
            print("Fetching Failed")
        }

        let allfetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        allfetchRequest.sortDescriptors = [NSSortDescriptor(key: "groupID", ascending: true)]
        do {
            allIdeaList = []
            allIdeaList = try context.fetch(allfetchRequest)
        } catch {
            print("Fetching Failed")
        }
        var tempGroupID: Int16 = 0
        groupList = []
        for idea in self.allIdeaList {
            if idea.groupID != tempGroupID && idea.isSave {
                groupList.append((idea.groupID, idea.groupName!))
                tempGroupID = idea.groupID
            }
            // todo: 二分探索にする
            // todo: 別メソッドにする. 付箋ボードビューでのみ名前の同期が必要
            if idea.groupID > 0 {
                for idea0 in self.ideas {
                    if idea.id == idea0.id {
                        idea.name = idea0.name
                    }
                }
            }
        }
    }

    func updateOrder() {
        var order: Int16 = 0
        for idea in ideas {
            idea.order = order
            order += 1
        }
    }

    func copyIdea(_ index: Int) -> Idea {
        let outIdea = Idea(context: context)
        outIdea.id = ideas[index].id
        outIdea.groupID = ideas[index].groupID
        outIdea.isSave = ideas[index].isSave
        outIdea.name = ideas[index].name
        outIdea.order = ideas[index].order
        outIdea.xRatio = ideas[index].xRatio
        outIdea.yRatio = ideas[index].yRatio
        outIdea.stickyFontSize = ideas[index].stickyFontSize
        outIdea.stickyWidth = ideas[index].stickyWidth
        outIdea.stickyHeight = ideas[index].stickyHeight
        outIdea.stickyRGBRed = ideas[index].stickyRGBRed
        outIdea.stickyRGBGreen = ideas[index].stickyRGBGreen
        outIdea.stickyRGBBlue = ideas[index].stickyRGBBlue
        return outIdea
    }

    func insertIdea(_ addIdea: Idea, _ insertIndex: Int) {
        ideas.insert(addIdea, at: insertIndex)
        updateOrder()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func deleteIdea(_ index: Int) {
        context.delete(ideas[index])
        ideas.remove(at: index)
        updateOrder()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func addNewIdea(_ name: String) {
        let idea = Idea(context: context)
        idea.id = NSUUID() as UUID
        idea.groupID = 0
        idea.isSave = false
        idea.isMemo = false
        idea.name = name
        idea.xRatio = 0
        idea.yRatio = 0
        idea.stickyFontSize = 12
        idea.stickyWidth = 100
        idea.stickyHeight = 80
        idea.stickyRGBRed = 1.0
        idea.stickyRGBGreen = 0.937
        idea.stickyRGBBlue = 0.522
        insertIdea(idea, 0)
    }

    func editIdea(_ name: String, _ index: Int) {
        self.ideas[index].name = name
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func editIdea(_ name: String, _ uuid: UUID) {
        let match = self.allIdeaList.filter({$0.id == uuid})
        for idea in match {
            idea.name = name
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func deleteIdea(_ uuid: UUID) {
        for idea in self.allIdeaList.filter({$0.id == uuid}) {
            self.allIdeaList.remove(at: self.allIdeaList.index(of: idea)!)
            context.delete(idea)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func sortIdea(_ sourceIndexPath: Int, _ destinationIndexPath: Int) {
        let idea = copyIdea(sourceIndexPath)
        deleteIdea(sourceIndexPath)
        insertIdea(idea, destinationIndexPath)
    }

    func addNewMemo(_ contents: String, _ groupID: Int16) -> Idea {
        let idea = Idea(context: context)
        idea.id = NSUUID() as UUID
        idea.groupID = groupID
        idea.isSave = false
        idea.isMemo = true
        idea.name = contents
        idea.xRatio = 0
        idea.yRatio = 0
        idea.stickyFontSize = 16
        idea.stickyWidth = 200
        idea.stickyHeight = 30
        idea.stickyRGBRed = 1
        idea.stickyRGBGreen = 1
        idea.stickyRGBBlue = 1
        self.allIdeaList.append(idea)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        return idea
    }

    func saveIdea(_ groupID: Int16, _ groupName: String) {
        for idea in allIdeaList {
            if idea.groupID == groupID {
                idea.groupName = groupName
                idea.isSave = true
                if let index = self.groupList.index(where: {$0.0 == groupID}) {
                    self.groupList[index].1 = groupName
                } else {
                    self.groupList.append((idea.groupID, idea.groupName!))
                }
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func deleteGroup(_ groupID: Int16, force: Bool) {
        for idea in allIdeaList {
            let isDelete = force ? true : !idea.isSave
            if idea.groupID == groupID && isDelete {
                context.delete(idea)
                if let index = self.groupList.index(where: {$0.0 == groupID}) {
                    self.groupList.remove(at: index)
                }
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func getGroup(_ groupID: Int16) -> [Idea]{
        var ideaList: [Idea] = []
        for idea in allIdeaList {
            if idea.groupID == groupID {
                ideaList.append(idea)
            }
        }
        return ideaList
    }
}
