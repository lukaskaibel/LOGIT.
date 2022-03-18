//
//  WorkoutRecorderList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import Foundation


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
    
    public func indexInSetGroup(for workoutSet: WorkoutSet) -> Int? {
        for setGroup in setGroups {
            if let index = setGroup.index(of: workoutSet) {
                return index
            }
        }
        return nil
    }
    
    public func addSet(to setGroup: WorkoutSetGroup) {
        database.newWorkoutSet(setGroup: setGroup)
        objectWillChange.send()
    }
    
        
    public func addSetGroup(with exercise: Exercise) {
        database.newWorkoutSetGroup(exercise: exercise, workout: workout)
        objectWillChange.send()
    }
    
    public func delete(set: WorkoutSet) {
        database.delete(set)
        objectWillChange.send()
    }
    
    public func delete(setGroup: WorkoutSetGroup) {
        database.delete(setGroup)
        objectWillChange.send()
    }
    
    public func deleteWorkout() {
        database.delete(workout)
        objectWillChange.send()
    }
    
    public func saveWorkout() {
        database.save()
    }
    
    private func startWorkout() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.workoutDuration += 1
        })
    }
    
}
