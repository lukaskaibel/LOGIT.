//
//  Database+Overview.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.09.23.
//

import Foundation
import CoreData
import SwiftUI
import OSLog

class OverviewController: ObservableObject {
    
    // MARK: - Constants

    static let shared = OverviewController()
    static let preview = OverviewController(isPreview: true)

    private let database: Database

    // MARK: - Init
    
    init(isPreview: Bool = false) {
        database = isPreview ? Database.preview : Database.shared
    }
    
    func save() {
        database.save()
    }
    
    var exerciseDetailOverviewItemCollection: OverviewItemCollection {
        let predicate = NSPredicate(format: "id == %@", OverviewItemCollection.CollectionType.exerciseDetail.rawValue)
        if let collection = database.fetch(OverviewItemCollection.self, predicate: predicate).first as? OverviewItemCollection {
            return collection
        } else {
            let collection = OverviewItemCollection(context: database.context)
            collection.id = OverviewItemCollection.CollectionType.exerciseDetail.rawValue
            
            let personalBest = OverviewItem(context: database.context)
            personalBest.id = OverviewItem.ItemType.personalBest.rawValue
            personalBest.isAdded = true
            collection.items.append(personalBest)
            
            let bestWeightPerDay = OverviewItem(context: database.context)
            bestWeightPerDay.id = OverviewItem.ItemType.bestWeightPerDay.rawValue
            bestWeightPerDay.isAdded = false
            collection.items.append(bestWeightPerDay)
            
            let bestRepetitionsPerDay = OverviewItem(context: database.context)
            bestRepetitionsPerDay.id = OverviewItem.ItemType.bestRepetitionsPerDay.rawValue
            bestRepetitionsPerDay.isAdded = false
            collection.items.append(bestRepetitionsPerDay)
            
            save()
            
            return collection
        }
    }
    
    var homeScreenOverviewItemCollection: OverviewItemCollection {
        let predicate = NSPredicate(format: "id == %@", OverviewItemCollection.CollectionType.homeScreen.rawValue)
        if let collection = database.fetch(OverviewItemCollection.self, predicate: predicate).first as? OverviewItemCollection {
            return collection
        } else {
            let collection = OverviewItemCollection(context: database.context)
            collection.id = OverviewItemCollection.CollectionType.homeScreen.rawValue
            
            let targetPerWeek = OverviewItem(context: database.context)
            targetPerWeek.id = OverviewItem.ItemType.targetPerWeek.rawValue
            targetPerWeek.isAdded = true
            collection.items.append(targetPerWeek)
            
            let muscleGroupsInLastTen = OverviewItem(context: database.context)
            muscleGroupsInLastTen.id = OverviewItem.ItemType.muscleGroupsInLastTen.rawValue
            muscleGroupsInLastTen.isAdded = false
            collection.items.append(muscleGroupsInLastTen)
            
            save()
            
            return collection
        }
    }
    
}
