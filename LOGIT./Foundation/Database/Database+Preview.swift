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
        
        (database.fetch(Workout.self) as! [Workout]).forEach { database.delete($0) }
        (database.fetch(Exercise.self) as! [Workout]).forEach { database.delete($0) }
        
        // MARK: Exercises
        
        let benchpress = database.newExercise(name: "Benchpress", muscleGroup: .chest)
        let inclinedBenchpress = database.newExercise(name: "Inclined Benchpress", muscleGroup: .chest)
        let overheadPress = database.newExercise(name: "Overhead Press", muscleGroup: .shoulders)
        let lateralRaises = database.newExercise(name: "Lateral Raises", muscleGroup: .shoulders)
        let tricepsExtensions = database.newExercise(name: "Triceps Extensions", muscleGroup: .triceps)
        let dips = database.newExercise(name: "Dips", muscleGroup: .chest)
        let squat = database.newExercise(name: "Squat", muscleGroup: .legs)
        let lunges = database.newExercise(name: "Lunges", muscleGroup: .legs)
        let legExtensions = database.newExercise(name: "Leg Extensions", muscleGroup: .legs)
        let deadlift = database.newExercise(name: "Deadlift", muscleGroup: .back)
        let standingRows = database.newExercise(name: "Standing Rows", muscleGroup: .back)
        let bicepsCurls = database.newExercise(name: "Biceps Curls", muscleGroup: .biceps)
        let latPulldown = database.newExercise(name: "Lat Pulldown", muscleGroup: .back)
        let crunches = database.newExercise(name: "Crunches", muscleGroup: .abdominals)
        
        for i in 0..<5 {
            var date = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: .now)!
            let pullday = database.newWorkout(name: "Pullday", date: date)
            let deadliftGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: deadlift, workout: pullday)
            database.newStandardSet(repetitions: 5, weight: 120, setGroup: deadliftGroup)
            database.newStandardSet(repetitions: 5, weight: 120, setGroup: deadliftGroup)
            database.newStandardSet(repetitions: 5, weight: 100, setGroup: deadliftGroup)
            database.newStandardSet(repetitions: 5, weight: 100, setGroup: deadliftGroup)
            let latGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: latPulldown, workout: pullday)
            database.newDropSet(repetitions: [5, 8], weights: [60, 45], setGroup: latGroup)
            database.newDropSet(repetitions: [5, 8], weights: [60, 45], setGroup: latGroup)
            database.newDropSet(repetitions: [5, 8], weights: [60, 45], setGroup: latGroup)
            let rowGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: standingRows, workout: pullday)
            database.newStandardSet(repetitions: 8, weight: 50, setGroup: rowGroup)
            database.newStandardSet(repetitions: 8, weight: 50, setGroup: rowGroup)
            database.newStandardSet(repetitions: 8, weight: 50, setGroup: rowGroup)
            database.newStandardSet(repetitions: 8, weight: 50, setGroup: rowGroup)
            let curlGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: bicepsCurls, workout: pullday)
            database.newStandardSet(repetitions: 12, weight: 30, setGroup: curlGroup)
            database.newStandardSet(repetitions: 12, weight: 30, setGroup: curlGroup)
            database.newStandardSet(repetitions: 12, weight: 30, setGroup: curlGroup)
            
            date = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: .now)!
            let pushday = database.newWorkout(name: "Pushday", date: date)
            let benchpressGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: benchpress, workout: pushday)
            database.newStandardSet(repetitions: 5, weight: 80, setGroup: benchpressGroup)
            database.newStandardSet(repetitions: 5, weight: 80, setGroup: benchpressGroup)
            database.newStandardSet(repetitions: 5, weight: 80, setGroup: benchpressGroup)
            database.newStandardSet(repetitions: 5, weight: 80, setGroup: benchpressGroup)
            database.newStandardSet(repetitions: 5, weight: 80, setGroup: benchpressGroup)
            let overheadPressGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: overheadPress, workout: pushday)
            database.newStandardSet(repetitions: 10, weight: 30, setGroup: overheadPressGroup)
            database.newStandardSet(repetitions: 10, weight: 30, setGroup: overheadPressGroup)
            database.newStandardSet(repetitions: 10, weight: 30, setGroup: overheadPressGroup)
            let inclinedBenchpressGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: inclinedBenchpress, workout: pushday)
            database.newStandardSet(repetitions: 12, weight: 50, setGroup: inclinedBenchpressGroup)
            database.newStandardSet(repetitions: 12, weight: 50, setGroup: inclinedBenchpressGroup)
            database.newStandardSet(repetitions: 12, weight: 50, setGroup: inclinedBenchpressGroup)
            let tricepsShoulderGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: tricepsExtensions, workout: pushday)
            tricepsShoulderGroup.secondaryExercise = lateralRaises
            database.newSuperSet(repetitionsFirstExercise: 12,
                                 repeptitionsSecondExercise: 14,
                                 weightFirstExercise: 25,
                                 weightSecondExercise: 18,
                                 setGroup: tricepsShoulderGroup)
            database.newSuperSet(repetitionsFirstExercise: 12,
                                 repeptitionsSecondExercise: 14,
                                 weightFirstExercise: 25,
                                 weightSecondExercise: 18,
                                 setGroup: tricepsShoulderGroup)
            database.newSuperSet(repetitionsFirstExercise: 12,
                                 repeptitionsSecondExercise: 14,
                                 weightFirstExercise: 25,
                                 weightSecondExercise: 18,
                                 setGroup: tricepsShoulderGroup)
            
            if i > 0 {
                date = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: .now)!
                let legday = database.newWorkout(name: "Legday", date: date)
                let squatGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: squat, workout: legday)
                database.newStandardSet(repetitions: 8, weight: 100, setGroup: squatGroup)
                database.newStandardSet(repetitions: 8, weight: 100, setGroup: squatGroup)
                database.newStandardSet(repetitions: 6, weight: 100, setGroup: squatGroup)
                database.newStandardSet(repetitions: 6, weight: 100, setGroup: squatGroup)
                let lungesGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: lunges, workout: legday)
                database.newStandardSet(repetitions: 12, weight: 50, setGroup: lungesGroup)
                database.newStandardSet(repetitions: 12, weight: 50, setGroup: lungesGroup)
                database.newStandardSet(repetitions: 12, weight: 50, setGroup: lungesGroup)
                database.newStandardSet(repetitions: 12, weight: 50, setGroup: lungesGroup)
                let legExtensionsGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: legExtensions, workout: legday)
                database.newDropSet(repetitions: [8, 5], weights: [40, 25], setGroup: legExtensionsGroup)
                database.newDropSet(repetitions: [6, 4], weights: [40, 25], setGroup: legExtensionsGroup)
                database.newDropSet(repetitions: [6, 4], weights: [40, 25], setGroup: legExtensionsGroup)
                let absGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false, exercise: crunches, workout: legday)
                database.newStandardSet(repetitions: 12, weight: 0, setGroup: absGroup)
                database.newStandardSet(repetitions: 12, weight: 0, setGroup: absGroup)
                database.newStandardSet(repetitions: 12, weight: 0, setGroup: absGroup)
            }
        }
        
        database.save()
        return database
    }
    
    var testWorkout: Workout {
        fetch(Workout.self).first as! Workout
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
        refreshObjects()
        return template
    }
    
}
