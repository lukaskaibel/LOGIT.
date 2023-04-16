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
    
    public var previousSetInSetGroup: WorkoutSet? {
        setGroup?.sets.value(at: (setGroup?.sets.firstIndex(of: self) ?? 0) - 1)
    }
    
    func isTraining(_ muscleGroup: MuscleGroup) -> Bool {
        setGroup?.exercise?.muscleGroup == muscleGroup || setGroup?.secondaryExercise?.muscleGroup == muscleGroup
    }
    
    public var isSuperSet: Bool { (self as? SuperSet) != nil }
    public var isDropSet: Bool { (self as? DropSet) != nil }
    
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
    
    public func match(_ workoutSet: WorkoutSet) {
        if let standardSet = self as? StandardSet, let workoutStandardSet = workoutSet as? StandardSet {
            standardSet.repetitions = workoutStandardSet.repetitions
            standardSet.weight = workoutStandardSet.weight
        } else if let dropSet = self as? DropSet, let workoutDropSet = workoutSet as? DropSet {
            dropSet.repetitions = workoutDropSet.repetitions
            dropSet.weights = workoutDropSet.weights
        } else if let superSet = self as? SuperSet, let workoutSuperSet = workoutSet as? SuperSet {
            superSet.repetitionsFirstExercise = workoutSuperSet.repetitionsFirstExercise
            superSet.repetitionsSecondExercise = workoutSuperSet.repetitionsSecondExercise
            superSet.weightFirstExercise = workoutSuperSet.weightFirstExercise
            superSet.weightSecondExercise = workoutSuperSet.weightSecondExercise
        }
    }
    
    // MARK: Methods to override for subclass
    
    @objc public var hasEntry: Bool {
        fatalError("WorkoutSet+: hasEntry must be implemented in subclass of WorkoutSet")
    }
    
    @objc public func clearEntries() {
        fatalError("WorkoutSet+: clearEntries must be implemented in subclass of WorkoutSet")
    }
    
}
