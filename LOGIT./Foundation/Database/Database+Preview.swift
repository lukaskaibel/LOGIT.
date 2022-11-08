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
                let exercise = database.newExercise(name: exampleExerciseNames.randomElement()!)
                let setGroup = database.newWorkoutSetGroup(exercise: exercise, workout: workout)
                for _ in 1..<Int.random(in: 1...8) {
                    let _ = database.newStandardSet(repetitions: Int.random(in: 0...10),
                                                    weight: Int.random(in: 0...200),
                                                    setGroup: setGroup)
                }
            }
        }
        database.save()
        return database
    }
    
    var testWorkout: Workout {
        let database = Database(isPreview: true)
        let exampleExerciseNames = ["Pushup", "Deadlift", "Squats", "Pushup", "Bar-Bell Curl", "Standing Row", "Overhead Press", "Inclined Dumbell Benchpress"]
        let workoutNames = ["Monday Morning Workout", "Thursday Afternoon Workout", "Pushday", "Pullday", "Leg-Day", "Full-Body Workout"]
        let workout = database.newWorkout(name: workoutNames.randomElement()!)
        for _ in 1..<Int.random(in: 4...10) {
            let exercise = database.newExercise(name: exampleExerciseNames.randomElement()!, muscleGroup: MuscleGroup.allCases.randomElement()!)
            let setGroup = database.newWorkoutSetGroup(exercise: exercise, workout: workout)
            for _ in 1..<Int.random(in: 5...8) {
                let _ = database.newStandardSet(repetitions: Int.random(in: 0...10),
                                                weight: Int.random(in: 0...200),
                                                setGroup: setGroup)
            }
        }
        database.save()
        database.refreshObjects()
        return workout
    }
    
    var testTemplate: Template {
        let exampleExerciseNames = ["Pushup", "Deadlift", "Squats", "Pushup", "Bar-Bell Curl"]
        let template = self.newTemplate(name: "Perfect Push-Day")
        for name in exampleExerciseNames {
            let exercise = self.newExercise(name: name, muscleGroup: MuscleGroup.allCases.randomElement()!)
            let setGroup = self.newTemplateSetGroup(exercise: exercise, template: template)
            for _ in 1..<Int.random(in: 2...5) {
                self.newTemplateStandardSet(repetitions: Int.random(in: 0...10),
                                                weight: Int.random(in: 0...150),
                                                setGroup: setGroup)
            }
        }
        self.save()
        return template
    }
    
}
