//
//  AllWorkouts.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.12.21.
//

import SwiftUI

final class AllWorkouts: ViewModel {
    
    //MARK: - Public
    
    enum SortingKey: String {
        case date, name
    }
    
    @Published var sortingKey: SortingKey = .date
    @Published var searchedText: String = ""
    
    var sectionedWorkouts: [[Workout]] {
        sectionWorkouts(by: sortingKey)
    }
        
    func header(for index: Int) -> String {
        switch sortingKey {
        case .date:
            return dateString(for: sectionedWorkouts[index].first?.date ?? .now)
        case .name:
            return String(sectionedWorkouts[index].first?.name?.first ?? " ").capitalized
        }
    }
    
    func firstLetterOfName(for workout: Workout) -> String {
        String(workout.name?.first ?? Character(" "))
    }
    
    
    func delete(workout: Workout) {
        database.delete(workout, saveContext: true)
    }
    
    //MARK: - Private
    
    private var filteredAndSortedWorkouts: [Workout] {
        database.fetch(Workout.self,
                       sortingKey: sortingKey.rawValue,
                       ascending: sortingKey == .name,
                       predicate: searchedText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@", searchedText)) as! [Workout]
    }
    
    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func sectionWorkouts(by sortingKey: SortingKey) -> [[Workout]] {
        var result = [[Workout]]()
        filteredAndSortedWorkouts
            .forEach { workout in
                switch sortingKey {
                case .date:
                    if let lastDate = result.last?.last?.date,
                        let workoutDate = workout.date,
                        Calendar.current.isDate(lastDate, equalTo: workoutDate, toGranularity: .month) {
                        result[result.count - 1].append(workout)
                    } else {
                        result.append([workout])
                    }
                case .name:
                    if let firstLetterOfLastWorkoutName = result.last?.last?.name?.first,
                        let workoutFirstLetter = workout.name?.first,
                        firstLetterOfLastWorkoutName == workoutFirstLetter {
                        result[result.count - 1].append(workout)
                    } else {
                        result.append([workout])
                    }
                }
            }
        return result
    }
    
}
