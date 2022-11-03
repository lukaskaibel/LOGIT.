//
//  Database+WorkoutSetConvert.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.11.22.
//

import Foundation

extension Database {
    
    public func convertSetGroupToStandardSets(_ setGroup: WorkoutSetGroup) {
        setGroup.sets
            .forEach { convertToStandardSet($0) }
        objectWillChange.send()
    }
    
    private func convertToStandardSet(_ workoutSet: WorkoutSet) {
        if let dropSet = workoutSet as? DropSet {
            let standardSet = newStandardSet(repetitions: Int(dropSet.repetitions?.first ?? 0),
                                                  weight: Int(dropSet.weights?.first ?? 0))
            dropSet.setGroup?.sets.replaceValue(at: dropSet.setGroup?.index(of: dropSet) ?? 0, with: standardSet)
            delete(dropSet)
        } else if let superSet = workoutSet as? SuperSet {
            let standardSet = newStandardSet(repetitions: Int(superSet.repetitionsFirstExercise),
                                                      weight: Int(superSet.weightFirstExercise))
            superSet.setGroup?.sets.replaceValue(at: superSet.setGroup?.index(of: superSet) ?? 0, with: standardSet)
            delete(superSet)
        }
    }
    
    public func convertSetGroupToDropSets(_ setGroup: WorkoutSetGroup) {
        setGroup.sets
            .forEach { convertToDropSet($0) }
        objectWillChange.send()
    }
    
    private func convertToDropSet(_ workoutSet: WorkoutSet)  {
        if let standardSet = workoutSet as? StandardSet {
            let dropSet = newDropSet(repetitions: [standardSet.repetitions].map { Int($0) },
                                              weights: [standardSet.weight].map { Int($0) })
            standardSet.setGroup?.sets.replaceValue(at: standardSet.setGroup?.index(of: standardSet) ?? 0, with: dropSet)
            delete(workoutSet)
        } else if let superSet = workoutSet as? SuperSet {
            let dropSet = newDropSet(repetitions: [superSet.repetitionsFirstExercise].map { Int($0) },
                                              weights: [superSet.weightFirstExercise].map { Int($0) })
            superSet.setGroup?.sets.replaceValue(at: superSet.setGroup?.index(of: superSet) ?? 0, with: dropSet)
            delete(superSet)
        }
    }
    
    public func convertSetGroupToSuperSets(_ setGroup: WorkoutSetGroup) {
        setGroup.sets
            .forEach { convertToSuperSet($0) }
        objectWillChange.send()
    }
    
    private func convertToSuperSet(_ workoutSet: WorkoutSet) {
        if let standardSet = workoutSet as? StandardSet {
            let superSet = newSuperSet(repetitionsFirstExercise: Int(standardSet.repetitions),
                                                weightFirstExercise: Int(standardSet.weight))
            standardSet.setGroup?.sets.replaceValue(at: standardSet.setGroup?.index(of: standardSet) ?? 0, with: superSet)
            delete(standardSet)
        } else if let dropSet = workoutSet as? DropSet {
            let superSet = newSuperSet(repetitionsFirstExercise: Int(dropSet.repetitions?.first ?? 0),
                                                weightFirstExercise: Int(dropSet.weights?.first ?? 0))
            dropSet.setGroup?.sets.replaceValue(at: dropSet.setGroup?.index(of: dropSet) ?? 0, with: superSet)
            delete(dropSet)
        }
    }

    
}
