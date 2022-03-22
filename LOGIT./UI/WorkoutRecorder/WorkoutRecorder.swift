//
//  WorkoutRecorderList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import Foundation
import UIKit


class WorkoutRecorder: ObservableObject {
    
    @Published var workout: Workout
    @Published var workoutDuration: Int = 0
    @Published var setGroupWithSelectedExercise: WorkoutSetGroup? = nil
    
    private var database: Database
    private var timer: Timer?
    
    public init(database: Database) {
        self.database = database
        workout = database.newWorkout()
        startWorkout()
    }
    
    public var workoutName: String {
        get { workout.name ?? "" }
        set { workout.name = newValue }
    }
    
    public var setGroups: [WorkoutSetGroup] {
        workout.setGroups?.array as? [WorkoutSetGroup] ?? [WorkoutSetGroup]()
    }
    
    public var workoutHasEntries: Bool {
        setsWithoutRepsAndWeight.count != workout.numberOfSets
    }
   
    public var setsWithoutRepsAndWeight: [WorkoutSet] {
        workout.sets.filter { $0.repetitions == 0 && $0.weight == 0 }
    }
    
    public func deleteSetsWithoutRepsAndWeight() {
        for workoutSet in setsWithoutRepsAndWeight {
            database.delete(workoutSet)
        }
    }
    
    public func indexInSetGroup(for workoutSet: WorkoutSet) -> Int? {
        for setGroup in setGroups {
            if let index = setGroup.index(of: workoutSet) {
                return index
            }
        }
        return nil
    }
    
    public func updateView() {
        objectWillChange.send()
    }
    
    public func addSet(to setGroup: WorkoutSetGroup) {
        database.newWorkoutSet(setGroup: setGroup)
        updateView()
    }
        
    public func addSetGroup(with exercise: Exercise) {
        database.newWorkoutSetGroup(exercise: exercise, workout: workout)
        updateView()
    }
    
    public func delete(set: WorkoutSet) {
        database.delete(set)
        updateView()
    }
    
    public func delete(setGroup: WorkoutSetGroup) {
        database.delete(setGroup)
        updateView()
    }
    
    public func deleteWorkout() {
        database.delete(workout)
        updateView()
    }
    
    public func saveWorkout() {
        if workout.name?.isEmpty ?? true {
            workout.name = Workout.getStandardName(for: Date())
        }
        database.save()
    }
    
    private func startWorkout() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.workoutDuration += 1
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
}
