//
//  EditExercise.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.03.22.
//

import Foundation

final class EditExercise: ViewModel {
    
    @Published var exerciseName: String = ""
    let exerciseToEdit: Exercise?
        
    init(exerciseToEdit: Exercise? = nil) {
        self.exerciseToEdit = exerciseToEdit
        if let exercise = exerciseToEdit, let exerciseName = exercise.name {
            self.exerciseName = exerciseName
        }
        super.init()
    }
    
    private var exercises: [Exercise] {
        database.fetch(Exercise.self) as! [Exercise]
    }
    
    func exerciseExistsWithName(_ name: String) -> Bool {
        return !name.isEmpty && !(exercises.filter { $0.name?.lowercased().trimmingCharacters(in: .whitespaces) == name.lowercased().trimmingCharacters(in: .whitespaces) }).isEmpty
    }
    
    func saveName() {
        if let exercise = exerciseToEdit {
            exercise.name = exerciseName
        } else {
            database.newExercise(name: exerciseName.trimmingCharacters(in: .whitespaces))
        }
        database.save()
        database.refreshObjects()
        objectWillChange.send()
    }

}
