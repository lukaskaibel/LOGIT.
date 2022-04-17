//
//  WorkoutRecorderList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import SwiftUI

class WorkoutRecorder: ViewModel {
    
    @Published var workout: Workout = Workout()
    @Published var setGroupWithSelectedExercise: WorkoutSetGroup? = nil
    @Published var exerciseForExerciseDetail: Exercise?
    @Published var selectedTimerDuration: Int = 0
    
    public var template: TemplateWorkout? {
        didSet { updateWorkoutWithTemplate() }
    }
    
    private var workoutSetTemplateSetDictionary = [WorkoutSet:TemplateWorkoutSet]()
    
    public var showingExerciseDetail: Binding<Bool> {
        Binding(get: { self.exerciseForExerciseDetail != nil },
                set: { _ in self.exerciseForExerciseDetail = nil })
    }
        
    public override init() {
        super.init()
        workout = database.newWorkout()
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
    
    public func addSet(to setGroup: WorkoutSetGroup) {
        database.newWorkoutSet(setGroup: setGroup)
        updateView()
    }
        
    public func addSetGroup(with exercise: Exercise) {
        database.newWorkoutSetGroup(exercise: exercise, workout: workout)
        updateView()
    }
    
    public func delete(setGroupsWithIndexes indexSet: IndexSet) {
        if let setGroups = workout.setGroups?.array as? [WorkoutSetGroup] {
            for index in indexSet {
                database.delete(setGroups[index])
            }
            updateView()
        }
    }
    
    public func repetitionsPlaceholder(for workoutSet: WorkoutSet) -> String {
        if let template = workoutSetTemplateSetDictionary[workoutSet] {
            return String(template.repetitions)
        }
        return "0"
    }
    
    public func weightPlaceholder(for workoutSet: WorkoutSet) -> String {
        if let template = workoutSetTemplateSetDictionary[workoutSet] {
            return String(convertWeightForDisplaying(template.weight))
        }
        return "0"
    }
    
    public func templateSet(for workoutSet: WorkoutSet) -> TemplateWorkoutSet? {
        workoutSetTemplateSetDictionary[workoutSet]
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
    
    public func updateWorkoutWithTemplate() {
        if let template = template {
            template.addToWorkouts(workout)
            workout.name = template.name
            for templateSetGroup in template.setGroups?.array as? [TemplateWorkoutSetGroup] ?? .emptyList {
                let setGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false,
                                                           exercise: templateSetGroup.exercise,
                                                           workout: workout)
                for templateSet in templateSetGroup.sets?.array as? [TemplateWorkoutSet] ?? .emptyList {
                    let workoutSet = database.newWorkoutSet(setGroup: setGroup)
                    workoutSetTemplateSetDictionary[workoutSet] = templateSet
                }
            }
        }
        updateView()
    }
    
    public func saveWorkout() {
        if workout.name?.isEmpty ?? true {
            workout.name = Workout.getStandardName(for: Date())
        }
        database.save()
    }
    
}
