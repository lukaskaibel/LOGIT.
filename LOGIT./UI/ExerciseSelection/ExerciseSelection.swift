//
//  ExerciseSelection.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 11.12.21.
//

import SwiftUI
import CoreData


final class ExerciseSelection: ViewModel {
    
    @Published var searchedText: String = ""
    
    var exercises: [Exercise] {
        database.fetch(Exercise.self,
                       sortingKey: "name",
                       ascending: true,
                       predicate: searchedText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@", searchedText)) as! [Exercise]
    }
    
    var groupedExercises: [[Exercise]] {
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
    
    func delete(exercise: Exercise) {
        database.delete(exercise)
        objectWillChange.send()
    }

}
