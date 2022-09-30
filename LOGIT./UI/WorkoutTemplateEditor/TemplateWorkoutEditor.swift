//
//  TemplateWorkoutEditor.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation


final class TemplateWorkoutEditor: ViewModel {
    
    @Published var templateWorkout = TemplateWorkout()
    @Published var setGroupWithSelectedExercise: TemplateWorkoutSetGroup? = nil
    @Published var isEditingExistingTemplate: Bool = false
    
    public var isSelectingSecondaryExercise = false
        
    init(templateWorkout: TemplateWorkout? = nil, from workout: Workout? = nil) {
        super.init()
        if let templateWorkout = templateWorkout {
            self.templateWorkout = templateWorkout
            self.isEditingExistingTemplate = true
        } else if let workout = workout {
            self.templateWorkout = database.newTemplateWorkout(from: workout)
            self.isEditingExistingTemplate = false
        } else {
            self.templateWorkout = database.newTemplateWorkout()
            self.isEditingExistingTemplate = false
        }
    }
    
    var templateWorkoutName: String {
        get {
            templateWorkout.name ?? ""
        }
        set {
            templateWorkout.name = newValue
            updateView()
        }
    }
    
    public var canSaveTemplate: Bool {
        !(templateWorkout.name?.isEmpty ?? true)
    }
    
    public var setGroups: [TemplateWorkoutSetGroup] {
        templateWorkout.setGroups
    }
    
    public func addSet(to templateSetGroup: TemplateWorkoutSetGroup) {
        let lastSet = templateSetGroup.sets.last
        if let _ = lastSet as? TemplateDropSet {
            database.newTemplateDropSet(templateSetGroup: templateSetGroup)
        } else if let _ = lastSet as? TemplateSuperSet {
            database.newTemplateSuperSet(setGroup: templateSetGroup)
        } else {
            database.newTemplateStandardSet(setGroup: templateSetGroup)
        }
        updateView()
    }
    
    public func addSetGroup(for exercise: Exercise) {
        database.newTemplateWorkoutSetGroup(exercise: exercise, templateWorkout: templateWorkout)
    }
        
    public func delete(setGroupWithIndexes indexSet: IndexSet) {
        for index in indexSet {
            database.delete(setGroups[index])
        }
        updateView()
    }
    
    public func delete(setsWithIndices indexSet: IndexSet, in setGroup: TemplateWorkoutSetGroup) {
        for index in indexSet {
            database.delete(setGroup.sets[index])
        }
        updateView()
    }
    
    public func indexInSetGroup(for templateSet: TemplateSet) -> Int? {
        for setGroup in setGroups {
            if let index = setGroup.index(of: templateSet) {
                return index
            }
        }
        return nil
    }
    
    public func moveSetGroups(from source: IndexSet, to destination: Int) {
        templateWorkout.setGroups.move(fromOffsets: source, toOffset: destination)
        database.refreshObjects()
        updateView()
    }

    public func saveTemplateWorkout() {
        database.save()
    }
    
    public func deleteTemplateWorkout() {
        database.delete(templateWorkout, saveContext: true)
    }
    
    //MARK: TemplateDropSet Functions
    
    func addDrop(to templateDropSet: TemplateDropSet) {
        templateDropSet.addDrop()
        updateView()
    }
    
    func removeLastDrop(from templateDropSet: TemplateDropSet) {
        templateDropSet.removeLastDrop()
        database.refreshObjects()
        updateView()
    }
    
    //MARK: WorkoutSet convert functions
    
    public func convertSetGroupToStandardSets(_ templateSetGroup: TemplateWorkoutSetGroup) {
        templateSetGroup.sets
            .forEach { convertToStandardSet($0) }
        updateView()
    }
    
    private func convertToStandardSet(_ templateSet: TemplateSet) {
        if let templateDropSet = templateSet as? TemplateDropSet {
            let templateStandardSet = database.newTemplateStandardSet(repetitions: Int(templateDropSet.repetitions?.first ?? 0),
                                                  weight: Int(templateDropSet.weights?.first ?? 0))
            templateDropSet.setGroup?.sets.replaceValue(at: templateDropSet.setGroup?.index(of: templateDropSet) ?? 0, with: templateStandardSet)
            database.delete(templateDropSet)
        } else if let templateSuperSet = templateSet as? TemplateSuperSet {
            let templateStandardSet = database.newTemplateStandardSet(repetitions: Int(templateSuperSet.repetitionsFirstExercise),
                                                                      weight: Int(templateSuperSet.weightFirstExercise))
            templateSuperSet.setGroup?.sets.replaceValue(at: templateSuperSet.setGroup?.index(of: templateSuperSet) ?? 0, with: templateStandardSet)
            database.delete(templateSuperSet)
        }
    }
    
    public func convertSetGroupToTemplateDropSets(_ templateSetGroup: TemplateWorkoutSetGroup) {
        templateSetGroup.sets
            .forEach { convertToTemplateDropSet($0) }
        updateView()
    }
    
    private func convertToTemplateDropSet(_ templateSet: TemplateSet) {
        if let templateStandardSet = templateSet as? TemplateStandardSet {
            let templateDropSet = database.newTemplateDropSet(repetitions: [templateStandardSet.repetitions].map { Int($0) },
                                              weights: [templateStandardSet.weight].map { Int($0) })
            templateStandardSet.setGroup?.sets.replaceValue(at: templateStandardSet.setGroup?.index(of: templateStandardSet) ?? 0, with: templateDropSet)
            database.delete(templateStandardSet)
        } else if let templateSuperSet = templateSet as? TemplateSuperSet {
            let templateDropSet = database.newTemplateDropSet(repetitions: [Int(templateSuperSet.repetitionsFirstExercise)],
                                                              weights: [Int(templateSuperSet.weightFirstExercise)])
            templateSuperSet.setGroup?.sets.replaceValue(at: templateSuperSet.setGroup?.index(of: templateSuperSet) ?? 0, with: templateDropSet)
            database.delete(templateSuperSet)
        }
    }
    
    public func convertSetGroupToTemplateSuperSet(_ templateSetGroup: TemplateWorkoutSetGroup) {
        templateSetGroup.sets
            .forEach { convertToTemplateSuperSet($0) }
        updateView()
    }
    
    private func convertToTemplateSuperSet(_ templateSet: TemplateSet) {
        if let templateStandardSet = templateSet as? TemplateStandardSet {
            let templateSuperSet = database.newTemplateSuperSet(repetitionsFirstExercise: Int(templateStandardSet.repetitions),
                                                                weightFirstExercise: Int(templateStandardSet.weight))
            templateStandardSet.setGroup?.sets.replaceValue(at: templateStandardSet.setGroup?.index(of: templateStandardSet) ?? 0, with: templateSuperSet)
            database.delete(templateStandardSet)
        } else if let templateDropSet = templateSet as? TemplateDropSet {
            let templateSuperSet = database.newTemplateSuperSet(repetitionsFirstExercise: Int(templateDropSet.repetitions?.first ?? 0),
                                                                weightFirstExercise: Int(templateDropSet.weights?.first ?? 0))
            templateDropSet.setGroup?.sets.replaceValue(at: templateDropSet.setGroup?.index(of: templateDropSet) ?? 0, with: templateSuperSet)
            database.delete(templateDropSet)
        }
    }
    
}
