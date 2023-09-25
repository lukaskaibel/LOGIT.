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
    
    // MARK: - Statics

    static let shared = OverviewController()
    static let preview = OverviewController(isPreview: true)
    
    // MARK: - Constants

    private let database: Database

    // MARK: - Init
    
    init(isPreview: Bool = false) {
        database = isPreview ? Database.preview : .shared
    }
    
    func save() {
        database.save()
    }
    
    private func createItemIfNotExisting(withId id: String, for collection: OverviewItemCollection, isAdded: Bool) {
        guard !collection.items.map({ $0.id }).contains(where: { $0 == id }) else { return }
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
        
        createItemIfNotExisting(withId: OverviewItemType.personalBest.rawValue, for: collection!, isAdded: true)
        createItemIfNotExisting(withId: OverviewItemType.bestWeightPerDay.rawValue, for: collection!, isAdded: false)
        createItemIfNotExisting(withId: OverviewItemType.bestRepetitionsPerDay.rawValue, for: collection!, isAdded: false)
            
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
        
        createItemIfNotExisting(withId: OverviewItemType.targetPerWeek.rawValue, for: collection!, isAdded: true)
        createItemIfNotExisting(withId: OverviewItemType.muscleGroupsInLastTen.rawValue, for: collection!, isAdded: false)
        createItemIfNotExisting(withId: OverviewItemType.setsPerWeek.rawValue, for: collection!, isAdded: false)
        createItemIfNotExisting(withId: OverviewItemType.measurement(.bodyWeight).rawValue, for: collection!, isAdded: false)
        createItemIfNotExisting(withId: OverviewItemType.measurement(.calories).rawValue, for: collection!, isAdded: false)
            
        save()
        
        return collection!
    }
    
}
