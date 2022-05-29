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
    
    public static func == (lhs: WorkoutSet, rhs: WorkoutSet) -> Bool {
        return lhs.objectID == rhs.objectID
    }
    
    public var exercise: Exercise? {
        setGroup?.exercise
    }
    
    public var workout: Workout? {
        setGroup?.workout
    }
    
    public func match(_ templateSet: TemplateSet) {
        if let standardSet = self as? StandardSet, let templateStandardSet = templateSet as? TemplateStandardSet {
            standardSet.repetitions = templateStandardSet.repetitions
            standardSet.weight = templateStandardSet.weight
        } else if let dropSet = self as? DropSet, let templateDropSet = templateSet as? TemplateDropSet {
            dropSet.repetitions = templateDropSet.repetitions
            dropSet.weights = templateDropSet.weights
        } else if let superSet = self as? SuperSet, let templateSuperSet = templateSet as? TemplateSuperSet {
            superSet.repetitionsFirstExercise = templateSuperSet.repetitionsFirstExercise
            superSet.repetitionsSecondExercise = templateSuperSet.repetitionsSecondExercise
            superSet.weightFirstExercise = templateSuperSet.weightFirstExercise
            superSet.weightSecondExercise = templateSuperSet.weightSecondExercise
        }
    }
    
    //MARK: Subclass Method Interface
    
    @objc public var maxRepetitions: Int {
        fatalError("WorkoutSet+: maxRepetitions must be implemented in subclass of WorkoutSet")
    }
    
    @objc public var maxWeight: Int {
        fatalError("WorkoutSet+: maxWeight must be implemented in subclass of WorkoutSet")
    }
    
    @objc public var hasEntry: Bool {
        fatalError("WorkoutSet+: hasEntry must be implemented in subclass of WorkoutSet")
    }
    
    @objc public func clearEntries() {
        fatalError("WorkoutSet+: clearEntries must be implemented in subclass of WorkoutSet")
    }
    
}
