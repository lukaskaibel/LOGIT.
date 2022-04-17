//
//  AllWorkouts.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.12.21.
//

import SwiftUI
import CoreData


final class AllWorkouts: ViewModel {
    
    @Published var sortingKey: SortingKey = .date
    @Published var ascending: Bool = false
    @Published var searchedText: String = ""
        
    private var filteredAndSortedWorkouts: [Workout] {
        database.fetch(Workout.self,
                       sortingKey: sortingKey.rawValue,
                       ascending: ascending,
                       predicate: searchedText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@", searchedText)) as! [Workout]
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
        database.delete(workout, saveContext: true)
        objectWillChange.send()
    }
    
    enum SortingKey: String {
        case date, name
    }
    
}
