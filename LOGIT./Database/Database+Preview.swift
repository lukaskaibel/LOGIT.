//
//  Database+Preview.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 17.04.22.
//

import Foundation

extension Database {
    
    static var preview: Database {
        let database = Database(isPreview: true)
        let exampleExerciseNames = ["Pushup", "Deadlift", "Squats", "Pushup", "Bar-Bell Curl", "Standing Row", "Overhead Press", "Inclined Dumbell Benchpress"]
        let workoutNames = ["Monday Morning Workout", "Thursday Afternoon Workout", "Pushday", "Pullday", "Leg-Day", "Full-Body Workout"]
        for _ in 0..<Int.random(in: 1...20) {
            let workout = database.newWorkout(name: workoutNames.randomElement()!)
            for _ in 1..<Int.random(in: 1...10) {
                let exercise = database.newExercise(name: exampleExerciseNames.randomElement()!, isFavorite: Bool.random())
                let setGroup = database.newWorkoutSetGroup(exercise: exercise, workout: workout)
                for _ in 1..<Int.random(in: 1...8) {
                    let _ = database.newWorkoutSet(repetitions: Int.random(in: 0...10), time: Int.random(in: 0...60), weight: Int.random(in: 0...200), setGroup: setGroup)
                }
            }
        }
        database.save()
        return database
    }
    
}
