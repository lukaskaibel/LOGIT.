//
//  WorkoutSet+CoreDataProperties.swift
//  
//
//  Created by Lukas Kaibel on 28.02.22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension WorkoutSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSet> {
        return NSFetchRequest<WorkoutSet>(entityName: "WorkoutSet")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var repetitions: Int64
    @NSManaged public var time: Int64
    @NSManaged public var weight: Int64
    @NSManaged public var exercise: Exercise?
    @NSManaged public var workout: Workout?

}

extension WorkoutSet : Identifiable {

}
