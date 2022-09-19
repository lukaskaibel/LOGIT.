//
//  ExerciseDetail.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.01.22.
//

import SwiftUI
import CoreData

final class ExerciseDetail: ViewModel {
    
    public enum SetSortingKey {
        case date, maxRepetitions, maxWeight
    }

    @Published var setSortingKey: SetSortingKey = .date
    
    private var exerciseID: NSManagedObjectID
    
    init(exerciseID: NSManagedObjectID) {
        self.exerciseID = exerciseID
        super.init()
    }
    
    func with(exercise: Exercise) -> ExerciseDetail {
        self.exerciseID = exercise.objectID
        return self
    }
    
    var exercise: Exercise {
        get {
            database.object(with: exerciseID) as! Exercise
        }
        set {
            let exercise = database.object(with: exerciseID) as! Exercise
            exercise.name = newValue.name
            database.save()
        }
    }
    
    var sets: [WorkoutSet] {
        (database.fetch(WorkoutSet.self,
                       sortingKey: "setGroup.workout.date",
                       ascending: false) as! [WorkoutSet])
            .filter { $0.exercise == exercise || ($0 as? SuperSet)?.secondaryExercise == exercise }
            .sorted {
                switch setSortingKey {
                case .date: return false
                case .maxRepetitions: return $0.maxRepetitions > $1.maxRepetitions
                case .maxWeight: return $0.maxWeight > $1.maxWeight
                }
            }
    }
    
    private var workoutsWithExercise: [Workout] {
        (database.fetch(Workout.self,
                        sortingKey: "date",
                        ascending: true) as! [Workout])
            .filter { $0.exercises.contains(exercise) }
    }
    
    func deleteExercise() {
        database.delete(exercise, saveContext: true)
    }
    
    func personalBest(for attribute: WorkoutSet.Attribute) -> Int {
        database.fetch(WorkoutSet.self)
            .compactMap { $0 as? WorkoutSet }
            .filter { $0.exercise == exercise }
            .map { workoutSet in
                return attribute == .repetitions ? workoutSet.maxRepetitions : convertWeightForDisplaying(workoutSet.maxWeight) 
            }
            .max() ?? 0
    }
    
    func personalBests(for attribute: WorkoutSet.Attribute, per calendarComponent: Calendar.Component) -> [ChartEntry] {
        let numberOfValues = numberOfValues(for: calendarComponent)
        var result = [(String, Int)](repeating: ("", 0), count: numberOfValues)
        for i in 0..<numberOfValues {
            guard let iteratedDay = Calendar.current.date(byAdding: calendarComponent,
                                                          value: -i,
                                                          to: Date()) else { continue }
            result[i].0 = getFirstDayString(in: calendarComponent, for: iteratedDay)
            for workoutSet in exercise.sets {
                guard let setDate = workoutSet.setGroup?.workout?.date,
                        Calendar.current.isDate(setDate,
                                                equalTo: iteratedDay,
                                                toGranularity: calendarComponent) else { continue }
                switch attribute {
                case .repetitions: result[i].1 = max(result[i].1, Int(workoutSet.maxRepetitions))
                case .weight: result[i].1 = max(result[i].1, convertWeightForDisplaying(workoutSet.maxWeight))
                }
            }
        }
        return result.reversed().map { ChartEntry(xValue: $0.0, yValue: $0.1) }
    }
        
    private func getFirstDayString(in component: Calendar.Component, for date: Date) -> String {
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = component == .weekOfYear ? "dd.MM." : component == .month ? "MMM" : "yyyy"
        return formatter.string(from: firstDayOfWeek)
    }
    
    private func numberOfValues(for calendarComponent: Calendar.Component) -> Int {
        switch calendarComponent {
        case .month: return 12
        default: return 5
        }
    }
    
}

struct ChartEntry: Identifiable {
    let id = UUID()
    var xValue: String
    var yValue: Int
}
