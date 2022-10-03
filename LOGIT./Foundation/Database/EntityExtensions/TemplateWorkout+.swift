//
//  TemplateWorkout+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation

extension TemplateWorkout {
    
    var workouts: [Workout] {
        get {
            (workouts_?.allObjects as? [Workout] ?? .emptyList).sorted { $0.date ?? .now < $1.date ?? .now }
        }
        set {
            workouts_ = NSSet(array: newValue)
        }
    }
    
    var date: Date? {
        return workouts.last?.date
    }
    
    var setGroups: [TemplateWorkoutSetGroup] {
        get {
            return (templateSetGroupOrder ?? .emptyList)
                .compactMap { id in (setGroups_?.allObjects as? [TemplateWorkoutSetGroup])?.first { templateSetGroup in templateSetGroup.id == id } }
        }
        set {
            templateSetGroupOrder = newValue.map { $0.id! }
            setGroups_ = NSSet(array: newValue)
        }
    }
    
    var numberOfSetGroups: Int {
        setGroups.count
    }
    
    var exercises: [Exercise] {
        var result = [Exercise]()
        for setGroup in setGroups {
            if let exercise = setGroup.exercise {
                result.append(exercise)
            }
        }
        return result
    }
    
    func index(of templateSetGroup: TemplateWorkoutSetGroup) -> Int? {
        setGroups.firstIndex(of: templateSetGroup)
    }
    
    var muscleGroups: [MuscleGroup] {
        exercises
            .compactMap { $0.muscleGroup }
    }
    
}
