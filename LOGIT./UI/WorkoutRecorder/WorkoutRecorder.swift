//
//  WorkoutRecorderList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import SwiftUI

class WorkoutRecorder: ObservableObject {
    
    @Published var workout: Workout
    @Published var setGroupWithSelectedExercise: WorkoutSetGroup? = nil
    @Published var exerciseForExerciseDetail: Exercise?
    @Published var selectedTimerDuration: Int = 0
    
    public var showingExerciseDetail: Binding<Bool> {
        Binding(get: { self.exerciseForExerciseDetail != nil },
                set: { _ in self.exerciseForExerciseDetail = nil })
    }
    
    private var database: Database
    private var timer: Timer?
    private var workoutStartTime = Date()
    public var timerStartTime: Date?
    
    public init(database: Database) {
        self.database = database
        workout = database.newWorkout()
        //startWorkout()
    }
        
    public var timerTime: Int? {
        guard let date = timerStartTime else { return nil }
        let time = Int(NSInteger(date.timeIntervalSince(Date())) % 60)
        if time < 0 {
            timerStartTime = nil
            return nil
        } else {
            return time
        }
    }
        
    public var workoutName: String {
        get { workout.name ?? "" }
        set { workout.name = newValue }
    }
    
    public var setGroups: [WorkoutSetGroup] {
        workout.setGroups?.array as? [WorkoutSetGroup] ?? .emptyList
    }
    
    public func moveSetGroups(from source: IndexSet, to destination: Int) {
        if var setGroups = workout.setGroups?.array as? [WorkoutSetGroup] {
            setGroups.move(fromOffsets: source, toOffset: destination)
            workout.setGroups = NSOrderedSet(array: setGroups)
            database.refreshObjects()
            objectWillChange.send()
        }
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
    
    public func delete(exercisesWithIndices indexSet: IndexSet) {
        if let setGroups = workout.setGroups?.array as? [WorkoutSetGroup] {
            for index in indexSet {
                database.delete(setGroups[index])
            }
            updateView()
        }
    }
    
    public func delete(setsWithIndices indexSet: IndexSet, in setGroup: WorkoutSetGroup) {
        for index in indexSet {
            if let sets = setGroup.sets?.array as? [WorkoutSet] {
                database.delete(sets[index])
            }
        }
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
            self?.objectWillChange.send()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
}
