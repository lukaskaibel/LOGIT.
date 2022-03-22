//
//  AllWorkouts.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 12.12.21.
//

import SwiftUI
import CoreData


final class AllWorkouts: ObservableObject {
    
    @Published var sortingKey: SortingKey = .date
    @Published var ascending: Bool = false
    @Published var searchedText: String = ""
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private var filteredAndSortedWorkouts: [Workout] {
        do {
            let request = Workout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: sortingKey.rawValue, ascending: ascending)]
            if !searchedText.isEmpty {
               request.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchedText)
            }
            return try context.fetch(request)
        } catch {
            fatalError("Fetching Workouts failed: \(error)")
        }
    }
    
    var sectionedWorkouts: [[Workout]] {
        var result = [[Workout]]()
        for workout in filteredAndSortedWorkouts {
            if let lastDate = result.last?.last?.date,
                let workoutDate = workout.date,
                Calendar.current.isDate(lastDate, equalTo: workoutDate, toGranularity: .month) {
                result[result.count - 1].append(workout)
            } else {
                result.append([workout])
            }
        }
        return result
    }
    
    func delete(workout: Workout) {
        do {
            context.delete(workout)
            try context.save()
            objectWillChange.send()
        } catch {
            fatalError("Error deleting workout: \(error)")
        }
    }
    
    enum SortingKey: String {
        case date, name
    }
    
}
