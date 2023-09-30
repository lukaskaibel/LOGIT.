//
//  WidgetController.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.09.23.
//

import CoreData
import Foundation
import OSLog
import SwiftUI

class WidgetController: ObservableObject {

    // MARK: - Statics

    static let shared = WidgetController()
    static let preview = WidgetController(isPreview: true)

    // MARK: - Constants

    private let database: Database

    // MARK: - Init

    init(isPreview: Bool = false) {
        database = isPreview ? Database.preview : .shared
    }

    func save() {
        database.save()
    }

    private func createWidgetIfNotExisting(
        withId id: String,
        for collection: WidgetCollection,
        isAdded: Bool
    ) {
        guard !collection.items.map({ $0.id }).contains(where: { $0 == id }) else { return }
        let item = Widget(context: database.context)
        item.id = id
        item.isAdded = isAdded
        collection.items.append(item)
    }

    var exerciseDetailWidgetCollection: WidgetCollection {
        let predicate = NSPredicate(
            format: "id == %@",
            WidgetCollection.CollectionType.exerciseDetail.rawValue
        )
        var collection =
            database.fetch(WidgetCollection.self, predicate: predicate).first as? WidgetCollection

        if collection == nil {
            collection = WidgetCollection(context: database.context)
            collection!.id = WidgetCollection.CollectionType.exerciseDetail.rawValue
        }

        createWidgetIfNotExisting(
            withId: WidgetType.personalBest.rawValue,
            for: collection!,
            isAdded: true
        )
        createWidgetIfNotExisting(
            withId: WidgetType.bestWeightPerDay.rawValue,
            for: collection!,
            isAdded: false
        )
        createWidgetIfNotExisting(
            withId: WidgetType.bestRepetitionsPerDay.rawValue,
            for: collection!,
            isAdded: false
        )
        createWidgetIfNotExisting(
            withId: WidgetType.volumePerDay.rawValue,
            for: collection!,
            isAdded: false
        )
        createWidgetIfNotExisting(
            withId: WidgetType.exerciseSetsPerWeek.rawValue,
            for: collection!,
            isAdded: false
        )

        save()

        return collection!
    }

    var homeScreenWidgetCollection: WidgetCollection {
        let predicate = NSPredicate(
            format: "id == %@",
            WidgetCollection.CollectionType.homeScreen.rawValue
        )
        var collection =
            database.fetch(WidgetCollection.self, predicate: predicate).first as? WidgetCollection

        if collection == nil {
            collection = WidgetCollection(context: database.context)
            collection!.id = WidgetCollection.CollectionType.homeScreen.rawValue
        }

        createWidgetIfNotExisting(
            withId: WidgetType.targetPerWeek.rawValue,
            for: collection!,
            isAdded: true
        )
        createWidgetIfNotExisting(
            withId: WidgetType.muscleGroupsInLastTen.rawValue,
            for: collection!,
            isAdded: false
        )
        createWidgetIfNotExisting(
            withId: WidgetType.setsPerWeek.rawValue,
            for: collection!,
            isAdded: false
        )
        createWidgetIfNotExisting(
            withId: WidgetType.workoutsPerMonth.rawValue,
            for: collection!,
            isAdded: false
        )

        save()

        return collection!
    }

    var baseMeasurementCollection: WidgetCollection {
        let predicate = NSPredicate(
            format: "id == %@",
            WidgetCollection.CollectionType.baseMeasurements.rawValue
        )
        var collection =
            database.fetch(WidgetCollection.self, predicate: predicate).first as? WidgetCollection

        if collection == nil {
            collection = WidgetCollection(context: database.context)
            collection!.id = WidgetCollection.CollectionType.baseMeasurements.rawValue
        }

        createWidgetIfNotExisting(
            withId: WidgetType.measurement(.bodyweight).rawValue,
            for: collection!,
            isAdded: true
        )
        createWidgetIfNotExisting(
            withId: WidgetType.measurement(.calories).rawValue,
            for: collection!,
            isAdded: false
        )

        save()

        return collection!
    }

    var circumferenceMeasurementCollection: WidgetCollection {
        let predicate = NSPredicate(
            format: "id == %@",
            WidgetCollection.CollectionType.circumferenceMeasurements.rawValue
        )
        var collection =
            database.fetch(WidgetCollection.self, predicate: predicate).first as? WidgetCollection

        if collection == nil {
            collection = WidgetCollection(context: database.context)
            collection!.id = WidgetCollection.CollectionType.circumferenceMeasurements.rawValue
        }

        LengthMeasurementEntryType.allCases.reversed()
            .forEach {
                createWidgetIfNotExisting(
                    withId: WidgetType.measurement(.length($0)).rawValue,
                    for: collection!,
                    isAdded: false
                )
            }

        save()

        return collection!
    }

}
