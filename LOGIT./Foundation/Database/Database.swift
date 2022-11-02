//
//  Database.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.01.22.
//

import CoreData
import OSLog


class Database: ObservableObject {
    
    // MARK: - Constants
    
    static let shared = Database()
    
    private let container: NSPersistentContainer
    
    // MARK: - Init
    
    init(isPreview: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "LOGIT")
        if isPreview {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    // MARK: - Computed Properties
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Public Methods
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                objectWillChange.send()
                NotificationCenter.default.post(name: .databaseDidChange, object: nil, userInfo: nil)
            } catch {
                os_log("Database: Failed to save context: \(String(describing: error))")
            }
        }
    }
    
    func object(with objectID: NSManagedObjectID) -> NSManagedObject {
        context.object(with: objectID)
    }
    
    func fetch(_ type: NSManagedObject.Type,
               sortingKey: String? = nil,
               ascending: Bool = true,
               predicate: NSPredicate? = nil) -> [NSFetchRequestResult] {
        do {
            let request = type.fetchRequest()
            if let sortingKey = sortingKey {
                request.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: ascending)]
            }
            request.predicate = predicate
            return try context.fetch(request)
        } catch {
            fatalError("Database - Failed fetching \(type) with error: \(error)")
        }
    }

    func delete(_ object: NSManagedObject?, saveContext: Bool = false) {
        guard let object = object else { return }
        if let workoutSet = object as? WorkoutSet, let setGroup = workoutSet.setGroup, setGroup.numberOfSets <= 1 {
            delete(setGroup)
        }
        context.delete(object)
        refreshObjects()
        if saveContext {
            save()
        }
    }
    
    func refreshObjects() {
        context.refreshAllObjects()
    }
    
}


extension Notification.Name {
    
    static let databaseDidChange = Notification.Name("changesInDatabase")
    
}
