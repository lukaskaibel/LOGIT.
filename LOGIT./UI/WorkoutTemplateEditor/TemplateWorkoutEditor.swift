//
//  TemplateWorkoutEditor.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation


final class TemplateWorkoutEditor: ObservableObject {
    
    @Published var templateWorkout: TemplateWorkout
    @Published var setGroupWithSelectedExercise: TemplateWorkoutSetGroup? = nil
    @Published var isEditingExistingTemplate: Bool
    
    private var database = Database.shared
    
    init(templateWorkout: TemplateWorkout? = nil) {
        if let templateWorkout = templateWorkout {
            self.templateWorkout = templateWorkout
            self.isEditingExistingTemplate = true
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
        }
    }
    
    public var canSaveTemplate: Bool {
        !(templateWorkout.name?.isEmpty ?? true)
    }
    
    public var setGroups: [TemplateWorkoutSetGroup] {
        templateWorkout.setGroups?.array as? [TemplateWorkoutSetGroup] ?? .emptyList
    }
    
    public func addSet(to setGroup: TemplateWorkoutSetGroup) {
        database.newTemplateWorkoutSet(setGroup: setGroup)
        updateView()
    }
    
    public func addSetGroup(for exercise: Exercise) {
        database.newTemplateWorkoutSetGroup(exercise: exercise, templateWorkout: templateWorkout)
    }
    
    public func updateView() {
        objectWillChange.send()
    }
    
    public func delete(setGroupWithIndexes indexSet: IndexSet) {
        if let setGroups = templateWorkout.setGroups?.array as? [TemplateWorkoutSetGroup] {
            for index in indexSet {
                database.delete(setGroups[index])
            }
            updateView()
        }
    }
    
    public func delete(setsWithIndices indexSet: IndexSet, in setGroup: TemplateWorkoutSetGroup) {
        for index in indexSet {
            if let sets = setGroup.sets?.array as? [TemplateWorkoutSet] {
                database.delete(sets[index])
            }
        }
        updateView()
    }
    
    public func indexInSetGroup(for workoutSet: TemplateWorkoutSet) -> Int? {
        for setGroup in setGroups {
            if let index = setGroup.index(of: workoutSet) {
                return index
            }
        }
        return nil
    }
    
    public func moveSetGroups(from source: IndexSet, to destination: Int) {
        if var setGroups = templateWorkout.setGroups?.array as? [TemplateWorkoutSetGroup] {
            setGroups.move(fromOffsets: source, toOffset: destination)
            templateWorkout.setGroups = NSOrderedSet(array: setGroups)
            database.refreshObjects()
            updateView()
        }
    }

    public func saveTemplateWorkout() {
        database.save()
    }
    
    public func deleteTemplateWorkout() {
        database.delete(templateWorkout)
    }
    
}
