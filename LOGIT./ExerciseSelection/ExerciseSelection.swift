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
    
    func exerciseExistsWithName(_ name: String) -> Bool {
        return !name.isEmpty && !(exercises.filter { $0.name?.lowercased().trimmingCharacters(in: .whitespaces) == name.lowercased().trimmingCharacters(in: .whitespaces) }).isEmpty
    }
    
    func addExerciseWith(name: String) {
        do {
            let exercise = Exercise(context: context)
            exercise.name = name.trimmingCharacters(in: .whitespaces)
            try context.save()
            updateExercises()
            objectWillChange.send()
        } catch {
            fatalError("Adding exercise failed: \(error)")
        }
    }
    
    func deleteExercise(for indexSet: IndexSet) {
        do {
            for index in indexSet {
                context.delete(exercises[index])
                try context.save()
                updateExercises()
            }
        } catch {
            fatalError("Removing exercise failed: \(error)")
        }
    }
    
    func getExerciseWithName(_ name: String) -> Exercise? {
        do {
            let request = Exercise.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[c] %@", name)
            try exercises = context.fetch(request)
            return exercises.first
        } catch {
            fatalError("Fetching Exercises failed: \(error)")
        }
    }
    
    private func updateExercises() {
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
