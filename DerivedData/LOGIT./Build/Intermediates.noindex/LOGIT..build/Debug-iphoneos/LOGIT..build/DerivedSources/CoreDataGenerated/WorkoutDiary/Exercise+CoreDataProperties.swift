//
//  Exercise+CoreDataProperties.swift
//  
//
//  Created by Lukas Kaibel on 28.02.22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var attribute: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var sets: NSOrderedSet?

}

// MARK: Generated accessors for sets
extension Exercise {

    @objc(insertObject:inSetsAtIndex:)
    @NSManaged public func insertIntoSets(_ value: WorkoutSet, at idx: Int)

    @objc(removeObjectFromSetsAtIndex:)
    @NSManaged public func removeFromSets(at idx: Int)

    @objc(insertSets:atIndexes:)
    @NSManaged public func insertIntoSets(_ values: [WorkoutSet], at indexes: NSIndexSet)

    @objc(removeSetsAtIndexes:)
    @NSManaged public func removeFromSets(at indexes: NSIndexSet)

    @objc(replaceObjectInSetsAtIndex:withObject:)
    @NSManaged public func replaceSets(at idx: Int, with value: WorkoutSet)

    @objc(replaceSetsAtIndexes:withSets:)
    @NSManaged public func replaceSets(at indexes: NSIndexSet, with values: [WorkoutSet])

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: WorkoutSet)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: WorkoutSet)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSOrderedSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSOrderedSet)

}

extension Exercise : Identifiable {

}
