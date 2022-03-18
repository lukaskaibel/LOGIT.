//
//  Workout+.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 01.07.21.
//

import Foundation


extension Workout {
    
    var numberOfSets: Int {
        sets.count
    }
    var numberOfSetGroups: Int {
        setGroups?.array.count ?? 0
    }
    
    var isEmpty: Bool {
        setGroups?.array.isEmpty ?? true
    }
    
    var exercises: [Exercise] {
        var result = [Exercise]()
        if let array = setGroups?.array as? [WorkoutSetGroup] {
            for setGroup in array {
                if let exercise = setGroup.exercise {
                    result.append(exercise)
                }
            }
        }
        return result
    }
    
    var sets: [WorkoutSet] {
        var result = [WorkoutSet]()
        if let array = setGroups?.array as? [WorkoutSetGroup] {
            for setGroup in array {
                if let workoutSets = setGroup.sets?.array as? [WorkoutSet] {
                    result.append(contentsOf: workoutSets)
                }
            }
        }
        return result
    }
    
    func remove(setGroup: WorkoutSetGroup) {
        setGroups = NSOrderedSet(array: ((setGroups?.array as? [WorkoutSetGroup]) ?? .emptyList).filter { $0 != setGroup } )
    }
    
    func index(of setGroup: WorkoutSetGroup) -> Int? {
        (setGroups?.array as? [WorkoutSetGroup] ?? .emptyList).firstIndex(of: setGroup)
    }
    
}
