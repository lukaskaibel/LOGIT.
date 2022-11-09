//
//  Database+EntityFetching.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.11.22.
//

import Foundation

extension Database {
    
    // MARK: - Workout Fetch
    
    enum WorkoutSortingKey: String {
        case date, name
    }
    
    func getWorkouts(withNameIncluding filteredText: String = "",
                     sortedBy sortingKey: WorkoutSortingKey = .date) -> [Workout] {
        fetch(Workout.self,
              sortingKey: sortingKey.rawValue,
              ascending: sortingKey == .name,
              predicate: filteredText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@",
                                                                  filteredText)) as! [Workout]
    }
    
    func getGroupedWorkouts(withNameIncluding filteredText: String = "",
                            groupedBy sortingKey: WorkoutSortingKey = .date) -> [[Workout]] {
        var result = [[Workout]]()
        getWorkouts(withNameIncluding: filteredText, sortedBy: sortingKey)
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
    
    // MARK: - WorkoutSet Fetch
    
    enum WorkoutSetSortingKey {
        case date, maxRepetitions, maxWeight
    }
    
    func getWorkoutSets(with exercise: Exercise? = nil,
                        sortedBy sortingkey: WorkoutSetSortingKey = .date) -> [WorkoutSet] {
        (fetch(WorkoutSet.self,
              sortingKey: "setGroup.workout.date",
              ascending: false) as! [WorkoutSet])
            .filter { exercise == nil || $0.exercise == exercise || ($0 as? SuperSet)?.secondaryExercise == exercise }
            .sorted {
                switch sortingkey {
                case .date: return false
                case .maxRepetitions: return $0.maxRepetitions > $1.maxRepetitions
                case .maxWeight: return $0.maxWeight > $1.maxWeight
                }
            }
    }
    
    // MARK: - Exercise Fetch
    
    func getExercises(withNameIncluding filterText: String = "",
                      for muscleGroup: MuscleGroup? = nil) -> [Exercise] {
        (fetch(Exercise.self,
               sortingKey: "name",
               ascending: true,
               predicate: filterText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@",
                                                                 filterText)) as! [Exercise])
            .filter { muscleGroup == nil || $0.muscleGroup == muscleGroup }
    }
    
    func getGroupedExercises(withNameIncluding filterText: String = "",
                             for muscleGroup: MuscleGroup? = nil) -> [[Exercise]] {
        var result = [[Exercise]]()
        for exercise in getExercises(withNameIncluding: filterText, for: muscleGroup) {
            if let lastExerciseNameFirstLetter = result.last?.last?.name?.first,
                let exerciseFirstLetter = exercise.name?.first,
                lastExerciseNameFirstLetter == exerciseFirstLetter {
                result[result.count - 1].append(exercise)
            } else {
                result.append([exercise])
            }
        }
        return result
    }
    
    // MARK: - Template Fetch
    
    func getTemplates(withNameIncluding filterText: String = "") -> [Template] {
        (fetch(Template.self,
              sortingKey: "creationDate",
              ascending: false,
              predicate: filterText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@",
                                                                filterText)) as! [Template])
        .sorted { $0.lastUsed ?? .now > $1.lastUsed ?? .now }
    }
    
}
