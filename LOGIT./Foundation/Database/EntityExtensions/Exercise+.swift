//
//  Exercise+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.21.
//

import Foundation
import CoreData

extension Exercise {
    
    var muscleGroup: MuscleGroup? {
        get { MuscleGroup(rawValue: muscleGroupString ?? "")  }
        set { muscleGroupString = newValue?.rawValue }
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
    
    static let defaultExerciseNames: [String] = [
    "Push-ups",
    "Barbell Bench Press",
    "Dumbbell Bench Press",
    "Inclined Barbell Bench Press",
    "Inclined Dumbbell Bench Press",
    "Dumbbell Fly",
    "Cable Crossovers",
    
    "Pull-ups",
    "Chin-ups",
    "Australian Pull-ups",
    "Lat Pull-Downs",
    "Standing Barbell Rows",
    "Standing Dumbbell, Rows",
    "Sitting Rows",
    
    "Squats",
    "Leg Press",
    "Walking Lunges",
    "Barbell Lunges",
    "Dumbbell Lunges",
    "Leg Extension",
    "Leg Curls",
    "Deadlift",
    "Calf Raises",
    
    "Handstand Push-ups",
    "Military Press",
    "Shoulder Press",
    "Upright Rows",
    "Lateral Rows",
    "Rear Delt Raise",
    
    "Dips",
    "Tricep Pullovers",
    "Tricep Press",
    "Close Grip Bench Press",
    "Tricep Kickbacks",
    "Straight Bar Curl",
    "Dumbbell Curl",
    
    "Sit-ups",
    "Crunches",
    "Bicycles",
    "Leg Raises",
    "Hanging Knee Raises",
    "Plank",
    "Side Plank",
    
    "Face Pulls"
    ]
    
}


extension Array: Identifiable where Element: Exercise {
    
    public var id: NSManagedObjectID {
        first?.objectID ?? NSManagedObjectID()
    }
    
}
