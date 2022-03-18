//
//  Exercise+.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 29.06.21.
//

import Foundation


extension Exercise {
    
    static func testExercise() -> Exercise {
        let exercise = Exercise()
        exercise.name = "Bench Press"
        let setGroup = WorkoutSetGroup()
        let set = WorkoutSet()
        set.setGroup = setGroup
        set.repetitions = 12
        set.weight = 60
        set.time = 30
        return exercise
    }
    
    var sets: [WorkoutSet] {
        var result = [WorkoutSet]()
        if let array = setGroups?.array as? [WorkoutSetGroup] {
            for setGroup in array {
                if let sets = setGroup.sets?.array as? [WorkoutSet] {
                    result.append(contentsOf: sets)
                }
            }
        }
        return result
    }
    
}
