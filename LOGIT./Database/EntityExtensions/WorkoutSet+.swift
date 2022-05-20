//
//  WorkoutSet+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.05.22.
//

import Foundation

extension WorkoutSet {
    
    public enum Attribute: String {
        case repetitions, weight
    }
    
    public var exercise: Exercise? {
        setGroup?.exercise
    }
    
    var workout: Workout? {
        setGroup?.workout
    }
    
    @objc public var maxRepetitions: Int {
        fatalError("maxRepetitions must be implemented in subclass of WorkoutSet")
    }
    
    @objc public var maxWeight: Int {
        fatalError("maxWeight must be implemented in subclass of WorkoutSet")
    }
    
    @objc public var hasEntry: Bool {
        fatalError("hasEntry must be implemented in subclass of WorkoutSet")
    }
    
    @objc public func clearEntries() {
        fatalError("clearEntries must be implemented in subclass of WorkoutSet")
    }
    
    @objc public func match(_ templateSet: TemplateSet) {
        if let standardSet = self as? StandardSet, let templateStandardSet = templateSet as? TemplateStandardSet {
            standardSet.repetitions = templateStandardSet.repetitions
            standardSet.weight = templateStandardSet.weight
        } else if let dropSet = self as? DropSet, let templateDropSet = templateSet as? TemplateDropSet {
            dropSet.repetitions = templateDropSet.repetitions
            dropSet.weights = templateDropSet.weights
        } else {
            fatalError("match not implemented for SuperSet")
        }
    }
    
    static func == (lhs: WorkoutSet, rhs: WorkoutSet) -> Bool {
        return lhs.objectID == rhs.objectID
    }
    
}
