//
//  ExerciseSelection.swift
//  WorkoutDiary
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
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.exercises = [Exercise]()
        updateExercises()
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
    
    
}
