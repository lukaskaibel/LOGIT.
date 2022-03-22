//
//  ExerciseSelection.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 11.12.21.
//

import SwiftUI
import CoreData


final class ExerciseSelection: ObservableObject {
    
    @Published var exercises: [Exercise]
    @Published var searchedText: String = "" {
        didSet {
            updateExercises()
        }
    }
    
    private let context: NSManagedObjectContext
    private let database = Database.shared
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.exercises = [Exercise]()
        NotificationCenter.default.addObserver(self, selector: #selector(contextChanged), name: .NSManagedObjectContextObjectsDidChange, object: context)
        updateExercises()
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
        updateExercises()
        objectWillChange.send()
    }
        
    func updateExercises() {
        do {
            let request = Exercise.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            if !searchedText.isEmpty {
               request.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchedText)
            }
            exercises = try context.fetch(request)
        } catch {
            fatalError("Fetching Exercises failed: \(error)")
        }
    }
    
    @objc private func contextChanged() {
        updateExercises()
    }
    
}
