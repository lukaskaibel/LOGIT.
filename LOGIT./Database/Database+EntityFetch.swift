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
                     sortedBy sortingKey: WorkoutSortingKey = .date,
                     usingMuscleGroup muscleGroup: MuscleGroup? = nil) -> [Workout] {
        (fetch(Workout.self,
              sortingKey: sortingKey.rawValue,
              ascending: sortingKey == .name,
              predicate: filteredText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@",
                                                                  filteredText)) as! [Workout])
            .filter { muscleGroup == nil || ($0.exercises.map { $0.muscleGroup }).contains(muscleGroup) }
    }
    
    func getWorkouts(withNameIncluding filteredText: String = "",
                     sortedBy sortingKey: WorkoutSortingKey = .date,
                     for calendarComponent: Calendar.Component,
                     including date: Date) -> [Workout] {
        getWorkouts(withNameIncluding: filteredText, sortedBy: sortingKey)
            .filter {
                guard let workoutDate = $0.date else { return false }
                return Calendar.current.component(calendarComponent, from: workoutDate) == Calendar.current.component(calendarComponent, from: date)
            }
    }
    
    func getGroupedWorkouts(withNameIncluding filteredText: String = "",
                            groupedBy sortingKey: WorkoutSortingKey = .date,
                            usingMuscleGroup muscleGroup: MuscleGroup? = nil) -> [[Workout]] {
        var result = [[Workout]]()
        getWorkouts(withNameIncluding: filteredText, sortedBy: sortingKey, usingMuscleGroup: muscleGroup)
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
    
    func getWorkoutSetGroups(with exercise: Exercise? = nil) -> [WorkoutSetGroup] {
        (fetch(WorkoutSetGroup.self,
              sortingKey: "workout.date",
              ascending: false) as! [WorkoutSetGroup])
            .filter { exercise == nil || $0.exercise == exercise || $0.secondaryExercise == exercise }
    }
    
    func getGroupedWorkoutSetGroups(
        with exercise: Exercise? = nil,
        groupedBy sortingKey: WorkoutSortingKey = .date
    ) -> [[WorkoutSetGroup]] {
        var result = [[WorkoutSetGroup]]()
        getWorkoutSetGroups(with: exercise)
            .forEach { setGroup in
                if let lastDate = result.last?.last?.workout?.date,
                   let setGroupDate = setGroup.workout?.date,
                   Calendar.current.isDate(lastDate, equalTo: setGroupDate, toGranularity: .month) {
                    result[result.count - 1].append(setGroup)
                } else {
                    result.append([setGroup])
                }
            }
        return result
    }
    
    // MARK: - WorkoutSet Fetch
    
    func getWorkoutSets(with exercise: Exercise? = nil) -> [WorkoutSet] {
        (fetch(WorkoutSet.self,
              sortingKey: "setGroup.workout.date",
              ascending: false) as! [WorkoutSet])
            .filter { exercise == nil || $0.exercise == exercise || ($0 as? SuperSet)?.secondaryExercise == exercise }
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
    
    enum TemplateSortingKey {
        case lastUsed, name
    }
    
    func getTemplates(withNameIncluding filterText: String = "",
                      sortedBy sortingKey: TemplateSortingKey = .name,
                      usingMuscleGroup muscleGroup: MuscleGroup? = nil) -> [Template] {
        (fetch(Template.self,
              sortingKey: "creationDate",
              ascending: false,
              predicate: filterText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@",
                                                                filterText)) as! [Template])
        .sorted {
            switch sortingKey {
            case .name: return $0.name ?? "" < $1.name ?? ""
            case .lastUsed: return $0.lastUsed ?? .now > $1.lastUsed ?? .now
            }
        }
        .filter { muscleGroup == nil || ($0.exercises.map { $0.muscleGroup }).contains(muscleGroup) }
    }
    
    func getGroupedTemplates(withNameIncluding filteredText: String = "",
                             groupedBy sortingKey: TemplateSortingKey = .name,
                             usingMuscleGroup muscleGroup: MuscleGroup? = nil) -> [[Template]] {
        var result = [[Template]]()
        getTemplates(withNameIncluding: filteredText, sortedBy: sortingKey, usingMuscleGroup: muscleGroup)
            .forEach { template in
                switch sortingKey {
                case .name:
                    if let firstLetterOfLastTemplateName = result.last?.last?.name?.first,
                       let templateFirstLetter = template.name?.first,
                       firstLetterOfLastTemplateName == templateFirstLetter {
                        result[result.count - 1].append(template)
                    } else {
                        result.append([template])
                    }
                case .lastUsed:
                    if let lastLastUsed = result.last?.last?.lastUsed,
                       let templateLastUsed = template.lastUsed,
                       Calendar.current.isDate(templateLastUsed, equalTo: lastLastUsed, toGranularity: .month) {
                        result[result.count - 1].append(template)
                    } else if !result.isEmpty && result.last?.last?.lastUsed == nil && template.lastUsed == nil {
                        result[result.count - 1].append(template)
                    } else {
                        result.append([template])
                    }
                }
            }
        return result
    }
    
}
