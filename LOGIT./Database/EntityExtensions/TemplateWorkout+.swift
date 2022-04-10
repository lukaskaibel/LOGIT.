//
//  TemplateWorkout+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation

extension TemplateWorkout {
    
    var date: Date? {
        return (workouts?.array as? [Workout])?.last?.date
    }
    
    var numberOfSetGroups: Int {
        setGroups?.array.count ?? 0
    }
    
    var exercises: [Exercise] {
        var result = [Exercise]()
        if let array = setGroups?.array as? [TemplateWorkoutSetGroup] {
            for setGroup in array {
                if let exercise = setGroup.exercise {
                    result.append(exercise)
                }
            }
        }
        return result
    }
    
}
