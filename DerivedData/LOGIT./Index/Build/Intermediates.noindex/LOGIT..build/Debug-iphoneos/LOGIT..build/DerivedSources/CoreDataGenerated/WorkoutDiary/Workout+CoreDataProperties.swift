//
//  Workout+CoreDataProperties.swift
//  
//
//  Created by Lukas Kaibel on 28.02.22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var setGroups: NSOrderedSet?

}

// MARK: Generated accessors for setGroups
extension Workout {

    @objc(insertObject:inSetGroupsAtIndex:)
    @NSManaged public func insertIntoSetGroups(_ value: WorkoutSetGroup, at idx: Int)

    @objc(removeObjectFromSetGroupsAtIndex:)
    @NSManaged public func removeFromSetGroups(at idx: Int)

    @objc(insertSetGroups:atIndexes:)
    @NSManaged public func insertIntoSetGroups(_ values: [WorkoutSetGroup], at indexes: NSIndexSet)

    @objc(removeSetGroupsAtIndexes:)
    @NSManaged public func removeFromSetGroups(at indexes: NSIndexSet)

    @objc(replaceObjectInSetGroupsAtIndex:withObject:)
    @NSManaged public func replaceSetGroups(at idx: Int, with value: WorkoutSetGroup)

    @objc(replaceSetGroupsAtIndexes:withSetGroups:)
    @NSManaged public func replaceSetGroups(at indexes: NSIndexSet, with values: [WorkoutSetGroup])

    @objc(addSetGroupsObject:)
    @NSManaged public func addToSetGroups(_ value: WorkoutSetGroup)

    @objc(removeSetGroupsObject:)
    @NSManaged public func removeFromSetGroups(_ value: WorkoutSetGroup)

    @objc(addSetGroups:)
    @NSManaged public func addToSetGroups(_ values: NSOrderedSet)

    @objc(removeSetGroups:)
    @NSManaged public func removeFromSetGroups(_ values: NSOrderedSet)

}

extension Workout : Identifiable {

}
