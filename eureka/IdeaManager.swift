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

    func fetchIdea() {
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            ideas = []
            ideas = try context.fetch(fetchRequest)
        } catch {
            print("Fetching Failed")
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
        outIdea.name = ideas[index].name
        outIdea.order = ideas[index].order
        outIdea.xRatio = ideas[index].xRatio
        outIdea.yRatio = ideas[index].yRatio
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
        idea.name = name
        idea.xRatio = 0.05
        idea.yRatio = 0.05
        insertIdea(idea, 0)
    }

    func editIdea(_ name: String, _ index: Int) {
        let editIdea = copyIdea(index)
        editIdea.name = name
        deleteIdea(index)
        insertIdea(editIdea, index)
    }

    func sortIdea(_ sourceIndexPath: Int, _ destinationIndexPath: Int) {
        let idea = copyIdea(sourceIndexPath)
        deleteIdea(sourceIndexPath)
        insertIdea(idea, destinationIndexPath)
    }
}
