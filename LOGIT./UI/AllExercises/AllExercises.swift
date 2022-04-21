//
//  AllExercises.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 16.04.22.
//

import Foundation

final class AllExercises: ViewModel {
    
    @Published var searchedText = ""
    @Published var selectedMuscleGroup: MuscleGroup?
    
    private var exercises: [Exercise] {
        (database.fetch(Exercise.self,
                       sortingKey: "name",
                       ascending: true,
                       predicate: searchedText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@", searchedText)) as! [Exercise])
            .filter { $0.muscleGroup == selectedMuscleGroup ?? $0.muscleGroup }
    }
    
    public var groupedExercises: [[Exercise]] {
        var result = [[Exercise]]()
        for exercise in exercises {
            if let lastExerciseNameFirstLetter = result.last?.last?.name?.first, let exerciseFirstLetter = exercise.name?.first, lastExerciseNameFirstLetter == exerciseFirstLetter {
                result[result.count - 1].append(exercise)
            } else {
                result.append([exercise])
            }
        }
        return result
    }
    
    func getLetter(for group: [Exercise]) -> String {
        String(group.first?.name?.first ?? Character(" "))
    }
    
}
