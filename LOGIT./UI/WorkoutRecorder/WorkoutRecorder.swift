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
    
    private var workoutSetTemplateSetDictionary = [WorkoutSet:TemplateSet]()
    
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
        setsWithoutEntries.count != workout.numberOfSets
    }
   
    public var setsWithoutEntries: [WorkoutSet] {
        workout.sets.filter { !$0.hasEntry }
    }
    
    public func deleteSetsWithoutEntries() {
        for workoutSet in setsWithoutEntries {
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
        let lastSet = (setGroup.sets?.array as? [WorkoutSet] ?? .emptyList).last
        if let _ = lastSet as? DropSet {
            database.newDropSet(setGroup: setGroup)
        } else {
            database.newStandardSet(setGroup: setGroup)
        }
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
    
    //MARK: Placeholder Methods
    
    public func repetitionsPlaceholder(for standardSet: StandardSet) -> String {
        if let templateStandardSet = templateSet(for: standardSet) as? TemplateStandardSet {
            return String(templateStandardSet.repetitions)
        }
        return "0"
    }
    
    public func weightPlaceholder(for standardSet: StandardSet) -> String {
        if let templateStandardSet = templateSet(for: standardSet) as? TemplateStandardSet {
            return String(convertWeightForDisplaying(templateStandardSet.weight))
        }
        return "0"
    }
    
    public func repetitionsPlaceholder(for dropSet: DropSet) -> [String] {
        if let templateDropSet = templateSet(for: dropSet) as? TemplateDropSet {
            return templateDropSet.repetitions?.map { String($0) } ?? .emptyList
        }
        return ["0"]
    }
    
    public func weightsPlaceholder(for dropSet: DropSet) -> [String] {
        if let templateDropSet = templateSet(for: dropSet) as? TemplateDropSet {
            return templateDropSet.weights?.map { String(convertWeightForDisplaying($0)) } ?? .emptyList
        }
        return ["0"]
    }

    
    
    public func templateSet(for workoutSet: WorkoutSet) -> TemplateSet? {
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
        database.delete(workout, saveContext: true)
    }
    
    public func updateWorkoutWithTemplate() {
        if let template = template {
            template.addToWorkouts(workout)
            workout.name = template.name
            for templateSetGroup in template.setGroups?.array as? [TemplateWorkoutSetGroup] ?? .emptyList {
                let setGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false,
                                                           exercise: templateSetGroup.exercise,
                                                           workout: workout)
                templateSetGroup.sets?.array
                    .compactMap { $0 as? TemplateSet }
                    .forEach { templateSet in
                        if let templateStandardSet = templateSet as? TemplateStandardSet {
                            let standardSet = database.newStandardSet(setGroup: setGroup)
                            workoutSetTemplateSetDictionary[standardSet] = templateStandardSet
                        } else if let templateDropSet = templateSet as? TemplateDropSet {
                            let dropSet = database.newDropSet(from: templateDropSet, setGroup: setGroup)
                            workoutSetTemplateSetDictionary[dropSet] = templateDropSet
                        } else {
                            fatalError("Not implemented for SuperSet")
                        }
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
    
    //MARK: DropSet Functions
    
    func addDrop(to dropSet: DropSet) {
        dropSet.addDrop()
        updateView()
    }
    
    func removeLastDrop(from dropSet: DropSet) {
        dropSet.removeLastDrop()
        database.refreshObjects()
        updateView()
    }
    
    //MARK: WorkoutSet convert functions
    
    public func convertSetGroupToStandardSets(_ setGroup: WorkoutSetGroup) {
        (setGroup.sets?.array as? [WorkoutSet] ?? .emptyList)
            .forEach { convertToStandardSet($0) }
        updateView()
    }
    
    @discardableResult
    private func convertToStandardSet(_ workoutSet: WorkoutSet) -> StandardSet {
        var standardSet = StandardSet()
        if let standardSet_ = workoutSet as? StandardSet {
            standardSet = standardSet_
        } else if let dropSet = workoutSet as? DropSet {
            standardSet = database.newStandardSet(repetitions: Int(dropSet.repetitions?.first ?? 0),
                                                  weight: Int(dropSet.weights?.first ?? 0))
            dropSet.setGroup?.replaceSets(at: dropSet.setGroup?.index(of: dropSet) ?? 0, with: standardSet)
        } else {
            fatalError("StandardSet convertion not implemented")
        }
        database.delete(workoutSet)
        return standardSet
    }
    
    public func convertSetGroupToDropSets(_ setGroup: WorkoutSetGroup) {
        (setGroup.sets?.array as? [WorkoutSet] ?? .emptyList)
            .forEach { convertToDropSet($0) }
        updateView()
    }
    
    @discardableResult
    private func convertToDropSet(_ workoutSet: WorkoutSet) -> DropSet {
        var dropSet = DropSet()
        if let standardSet = workoutSet as? StandardSet {
            let dropSet = database.newDropSet(repetitions: [standardSet.repetitions].map { Int($0) },
                                              weights: [standardSet.weight].map { Int($0) })
            standardSet.setGroup?.replaceSets(at: standardSet.setGroup?.index(of: standardSet) ?? 0, with: dropSet)
        } else if let dropSet_ = workoutSet as? DropSet {
            dropSet = dropSet_
        } else {
            fatalError("Dropset convertion not implemented")
        }
        database.delete(workoutSet)
        return dropSet
    }
    
}
