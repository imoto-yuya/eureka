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
    }

    func fetchAllIdea() {
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "groupID", ascending: true)]
        do {
            allIdeaList = []
            allIdeaList = try context.fetch(fetchRequest)
        } catch {
            print("Fetching Failed")
        }
        var tempGroupID: Int16 = 0
        groupList = []
        var temp: [Int16] = []
        var temp2: Int16 = 0
        for idea in self.allIdeaList {
            if idea.groupID != temp2 {
                temp.append(idea.groupID)
                temp2 = idea.groupID
            }
            if idea.groupID != tempGroupID && idea.isSave {
                groupList.append((idea.groupID, idea.groupName!))
                tempGroupID = idea.groupID
            }
        }
        print(temp)
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

    func sortIdea(_ sourceIndexPath: Int, _ destinationIndexPath: Int) {
        let idea = copyIdea(sourceIndexPath)
        deleteIdea(sourceIndexPath)
        insertIdea(idea, destinationIndexPath)
    }

    func saveIdea(_ groupID: Int16, _ groupName: String) {
        for idea in allIdeaList {
            if idea.groupID == groupID {
                idea.groupName = groupName
                idea.isSave = true
                self.groupList.append((idea.groupID, idea.groupName!))
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    func deleteGroup(_ groupID: Int16, force: Bool) {
        for idea in allIdeaList {
            let isDelete = force ? true : !idea.isSave
            if idea.groupID == groupID && isDelete {
                context.delete(idea)
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
