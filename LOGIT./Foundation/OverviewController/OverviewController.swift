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
    
    private func createItemIfNotExisting(with id: String, for collection: OverviewItemCollection, isAdded: Bool) {
        guard !collection.items.map({ $0.type }).contains(where: { $0.rawValue == id }) else { return }
        let item = OverviewItem(context: database.context)
        item.id = id
        item.isAdded = isAdded
        collection.items.append(item)
    }
    
    var exerciseDetailOverviewItemCollection: OverviewItemCollection {
        let predicate = NSPredicate(format: "id == %@", OverviewItemCollection.CollectionType.exerciseDetail.rawValue)
        var collection = database.fetch(OverviewItemCollection.self, predicate: predicate).first as? OverviewItemCollection
        
        if collection == nil {
            collection = OverviewItemCollection(context: database.context)
            collection!.id = OverviewItemCollection.CollectionType.exerciseDetail.rawValue
        }
        
        createItemIfNotExisting(with: OverviewItem.ItemType.personalBest.rawValue, for: collection!, isAdded: true)
        createItemIfNotExisting(with: OverviewItem.ItemType.bestWeightPerDay.rawValue, for: collection!, isAdded: false)
        createItemIfNotExisting(with: OverviewItem.ItemType.bestRepetitionsPerDay.rawValue, for: collection!, isAdded: false)
            
        save()
        
        return collection!
    }
    
    var homeScreenOverviewItemCollection: OverviewItemCollection {
        let predicate = NSPredicate(format: "id == %@", OverviewItemCollection.CollectionType.homeScreen.rawValue)
        var collection = database.fetch(OverviewItemCollection.self, predicate: predicate).first as? OverviewItemCollection
        
        if collection == nil {
            collection = OverviewItemCollection(context: database.context)
            collection!.id = OverviewItemCollection.CollectionType.homeScreen.rawValue
        }
        
        createItemIfNotExisting(with: OverviewItem.ItemType.targetPerWeek.rawValue, for: collection!, isAdded: true)
        createItemIfNotExisting(with: OverviewItem.ItemType.muscleGroupsInLastTen.rawValue, for: collection!, isAdded: false)
        createItemIfNotExisting(with: OverviewItem.ItemType.setsPerWeek.rawValue, for: collection!, isAdded: false)
            
        save()
        
        return collection!
    }
    
}
