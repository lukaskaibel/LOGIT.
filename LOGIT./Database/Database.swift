//
//  Database.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.01.22.
//

import CoreData
import OSLog


struct Database {
    
    static let shared = Database()
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
    
    let container: NSPersistentContainer
    
    init(isPreview: Bool = false) {
        container = NSPersistentContainer(name: "WorkoutDiary")
        if isPreview {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                os_log("Database: Failed to save context: \(String(describing: error))")
            }
        }
    }
    
    func refreshObjects() {
        container.viewContext.refreshAllObjects()
    }
    
    @discardableResult
    func newWorkout(name: String = "", date: Date = Date(), setGroups: [WorkoutSetGroup] = [WorkoutSetGroup]()) -> Workout {
        let workout = Workout(context: container.viewContext)
        workout.name = name
        workout.date = date
        workout.setGroups = NSOrderedSet(array: setGroups)
        return workout
    }
    
    @discardableResult
    func newWorkoutSetGroup(sets: [WorkoutSet]? = nil, exercise: Exercise? = nil, workout: Workout? = nil) -> WorkoutSetGroup {
        let setGroup = WorkoutSetGroup(context: container.viewContext)
        if let sets = sets, !sets.isEmpty {
            setGroup.sets = NSOrderedSet(array: sets)
        } else {
            newWorkoutSet(setGroup: setGroup)
        }
        setGroup.exercise = exercise
        setGroup.workout = workout
        return setGroup
    }
    
    @discardableResult
    func newWorkoutSet(repetitions: Int = 0, time: Int = 0, weight: Int = 0, setGroup: WorkoutSetGroup? = nil) -> WorkoutSet {
        let workoutSet = WorkoutSet(context: container.viewContext)
        workoutSet.repetitions = Int64(repetitions)
        workoutSet.time = Int64(time)
        workoutSet.weight = Int64(weight)
        workoutSet.setGroup = setGroup
        return workoutSet
    }
    
    @discardableResult
    func newExercise(name: String = "", isFavorite: Bool = false, setGroups: [WorkoutSetGroup]? = nil) -> Exercise {
        let exercise = Exercise(context: container.viewContext)
        exercise.name = name
        exercise.isFavorite = isFavorite
        if let setGroups = setGroups {
            exercise.setGroups = NSOrderedSet(array: setGroups)
        }
        return exercise
    }
    
    func getExercises() -> [Exercise] {
        do {
            let request = Exercise.fetchRequest()
            return try container.viewContext.fetch(request)
        } catch {
            fatalError("Failed to fetch Exercises: \(error)")
        }
    }
    
    func delete(_ object: NSManagedObject, saveContext: Bool = false) {
        if let workoutSet = object as? WorkoutSet, let setGroup = workoutSet.setGroup, setGroup.numberOfSets <= 1 {
            delete(setGroup)
        }
        container.viewContext.delete(object)
        refreshObjects()
        if saveContext {
            save()
        }
    }
    
}


extension Database {
    
    var numberOfExercises: Int {
        do {
            return try container.viewContext.fetch(Exercise.fetchRequest()).count
        } catch {
            fatalError("Error fetching exercises: \(error)")
        }
    }
    
}
