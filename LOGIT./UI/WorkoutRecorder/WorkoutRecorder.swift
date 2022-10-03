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
    
    var isSelectingSecondaryExercise: Bool = false
    private var workoutSetTemplateSetDictionary = [WorkoutSet:TemplateSet]()
    
    public override init() {
        super.init()
        workout = database.newWorkout()
    }
    
    public var showingExerciseDetail: Binding<Bool> {
        Binding(get: { self.exerciseForExerciseDetail != nil },
                set: { _ in self.exerciseForExerciseDetail = nil })
    }
        
    public var workoutName: String {
        get { workout.name ?? "" }
        set { workout.name = newValue }
    }
    
    public var setGroups: [WorkoutSetGroup] {
        workout.setGroups
    }
    
    public func moveSetGroups(from source: IndexSet, to destination: Int) {
        workout.setGroups.move(fromOffsets: source, toOffset: destination)
        database.refreshObjects()
        objectWillChange.send()
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
        let lastSet = setGroup.sets.last
        if let _ = lastSet as? DropSet {
            database.newDropSet(setGroup: setGroup)
        } else if let _ = lastSet as? SuperSet {
            database.newSuperSet(setGroup: setGroup)
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
        for index in indexSet {
            database.delete(workout.setGroups[index])
        }
        updateView()
    }
    
    //MARK: Placeholder Methods
    
    public func repetitionsPlaceholder(for standardSet: StandardSet) -> String {
        guard let templateStandardSet = templateSet(for: standardSet) as? TemplateStandardSet else { return "0" }
        return String(templateStandardSet.repetitions)
    }
    
    public func weightPlaceholder(for standardSet: StandardSet) -> String {
        guard let templateStandardSet = templateSet(for: standardSet) as? TemplateStandardSet else { return "0" }
        return String(convertWeightForDisplaying(templateStandardSet.weight))
    }
    
    public func repetitionsPlaceholder(for dropSet: DropSet) -> [String] {
        guard let templateDropSet = templateSet(for: dropSet) as? TemplateDropSet else { return ["0"] }
        return templateDropSet.repetitions?.map { String($0) } ?? .emptyList
    }
    
    public func weightsPlaceholder(for dropSet: DropSet) -> [String] {
        guard let templateDropSet = templateSet(for: dropSet) as? TemplateDropSet else { return ["0"] }
        return templateDropSet.weights?.map { String(convertWeightForDisplaying($0)) } ?? .emptyList
    }
    
    public func repetitionsPlaceholder(for superSet: SuperSet) -> [String] {
        guard let templateSuperSet = templateSet(for: superSet) as? TemplateSuperSet else { return ["0", "0"] }
        return [templateSuperSet.repetitionsFirstExercise, templateSuperSet.repetitionsSecondExercise]
            .map { String($0) }
    }
    
    public func weightsPlaceholder(for superSet: SuperSet) -> [String] {
        guard let templateSuperSet = templateSet(for: superSet) as? TemplateSuperSet else { return ["0", "0"] }
        return [templateSuperSet.weightFirstExercise, templateSuperSet.weightSecondExercise]
            .map { String(convertWeightForDisplaying($0)) }
    }
    
    public func templateSet(for workoutSet: WorkoutSet) -> TemplateSet? {
        workoutSetTemplateSetDictionary[workoutSet]
    }
    
    public func delete(setsWithIndices indexSet: IndexSet, in setGroup: WorkoutSetGroup) {
        for index in indexSet {
            database.delete(setGroup.sets[index])
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
    
    public func updateWorkout(with template: TemplateWorkout){
        template.workouts.append(workout)
        workout.name = template.name
        for templateSetGroup in template.setGroups {
            let setGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false,
                                                       exercise: templateSetGroup.exercise,
                                                       workout: workout)
            templateSetGroup.sets
                .forEach { templateSet in
                    if let templateStandardSet = templateSet as? TemplateStandardSet {
                        let standardSet = database.newStandardSet(setGroup: setGroup)
                        workoutSetTemplateSetDictionary[standardSet] = templateStandardSet
                    } else if let templateDropSet = templateSet as? TemplateDropSet {
                        let dropSet = database.newDropSet(from: templateDropSet, setGroup: setGroup)
                        workoutSetTemplateSetDictionary[dropSet] = templateDropSet
                    } else if let templateSuperSet = templateSet as? TemplateSuperSet {
                        let superSet = database.newSuperSet(from: templateSuperSet, setGroup: setGroup)
                        workoutSetTemplateSetDictionary[superSet] = templateSuperSet
                    }
                }
        }
        updateView()
    }
    
    public func saveWorkout() {
        if workout.name?.isEmpty ?? true {
            workout.name = Workout.getStandardName(for: Date())
        }
        workout.endDate = .now
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
        setGroup.sets
            .forEach { convertToStandardSet($0) }
        updateView()
    }
    
    private func convertToStandardSet(_ workoutSet: WorkoutSet) {
        if let dropSet = workoutSet as? DropSet {
            let standardSet = database.newStandardSet(repetitions: Int(dropSet.repetitions?.first ?? 0),
                                                  weight: Int(dropSet.weights?.first ?? 0))
            dropSet.setGroup?.sets.replaceValue(at: dropSet.setGroup?.index(of: dropSet) ?? 0, with: standardSet)
            database.delete(dropSet)
        } else if let superSet = workoutSet as? SuperSet {
            let standardSet = database.newStandardSet(repetitions: Int(superSet.repetitionsFirstExercise),
                                                      weight: Int(superSet.weightFirstExercise))
            superSet.setGroup?.sets.replaceValue(at: superSet.setGroup?.index(of: superSet) ?? 0, with: standardSet)
            database.delete(superSet)
        }
    }
    
    public func convertSetGroupToDropSets(_ setGroup: WorkoutSetGroup) {
        setGroup.sets
            .forEach { convertToDropSet($0) }
        updateView()
    }
    
    private func convertToDropSet(_ workoutSet: WorkoutSet)  {
        if let standardSet = workoutSet as? StandardSet {
            let dropSet = database.newDropSet(repetitions: [standardSet.repetitions].map { Int($0) },
                                              weights: [standardSet.weight].map { Int($0) })
            standardSet.setGroup?.sets.replaceValue(at: standardSet.setGroup?.index(of: standardSet) ?? 0, with: dropSet)
            database.delete(workoutSet)
        } else if let superSet = workoutSet as? SuperSet {
            let dropSet = database.newDropSet(repetitions: [superSet.repetitionsFirstExercise].map { Int($0) },
                                              weights: [superSet.weightFirstExercise].map { Int($0) })
            superSet.setGroup?.sets.replaceValue(at: superSet.setGroup?.index(of: superSet) ?? 0, with: dropSet)
            database.delete(superSet)
        }
    }
    
    public func convertSetGroupToSuperSets(_ setGroup: WorkoutSetGroup) {
        setGroup.sets
            .forEach { convertToSuperSet($0) }
        updateView()
    }
    
    private func convertToSuperSet(_ workoutSet: WorkoutSet) {
        if let standardSet = workoutSet as? StandardSet {
            let superSet = database.newSuperSet(repetitionsFirstExercise: Int(standardSet.repetitions),
                                                weightFirstExercise: Int(standardSet.weight))
            standardSet.setGroup?.sets.replaceValue(at: standardSet.setGroup?.index(of: standardSet) ?? 0, with: superSet)
            database.delete(standardSet)
        } else if let dropSet = workoutSet as? DropSet {
            let superSet = database.newSuperSet(repetitionsFirstExercise: Int(dropSet.repetitions?.first ?? 0),
                                                weightFirstExercise: Int(dropSet.weights?.first ?? 0))
            dropSet.setGroup?.sets.replaceValue(at: dropSet.setGroup?.index(of: dropSet) ?? 0, with: superSet)
            database.delete(dropSet)
        }
    }
    
}
