//
//  EditExercise.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.03.22.
//

import Foundation
import CoreData

final class EditExercise: ViewModel {
    
    //MARK: - Variables
    
    @Published var exerciseName: String = ""
    @Published var muscleGroup: MuscleGroup = .chest
    
    var exerciseToEdit: Exercise?
    
    //MARK: - Init
        
    init(exerciseToEdit: Exercise? = nil) {
        super.init()
        if let exerciseToEdit = exerciseToEdit {
            self.exerciseToEdit = exerciseToEdit
            exerciseName = exerciseToEdit.name ?? ""
            muscleGroup = exerciseToEdit.muscleGroup ?? .chest
        }
    }
    
    //MARK: - Public Methods
    
    var isEditingExistingExercise: Bool {
        exerciseToEdit != nil
    }
    
    func nameIsEmpty() -> Bool {
        exerciseName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func exerciseAlreadyExists() -> Bool {
        exercises
            .compactMap { $0.name?.lowercased().trimmingCharacters(in: .whitespaces) }
            .contains(exerciseName.lowercased().trimmingCharacters(in: .whitespaces))
    }
    
    func save() {
        if let exerciseToEdit = exerciseToEdit {
            exerciseToEdit.name = exerciseName
            exerciseToEdit.muscleGroup = muscleGroup
        } else {
            database.newExercise(name: exerciseName, muscleGroup: muscleGroup)
        }
        database.save()
    }
    
    //MARK: - Private Methods
    
    private var exercises: [Exercise] {
        database.fetch(Exercise.self) as! [Exercise]
    }

}
