//
//  ExerciseDetail.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.01.22.
//

import SwiftUI
import CoreData

final class ExerciseDetail: ViewModel {
    
    @Published var selectedAttribute: WorkoutSet.Attribute = .weight
    @Published var selectedCalendarComponentForRepetitions: Calendar.Component = .weekOfYear
    @Published var selectedCalendarComponentForWeight: Calendar.Component = .weekOfYear
    
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
            .filter { $0.exercise == exercise }
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
        let workoutSets = (database.fetch(WorkoutSet.self,
                                          sortingKey: attribute == .repetitions ? "repetitions" : "weight",
                                          ascending: false) as! [WorkoutSet]).filter { $0.exercise == exercise }
        return attribute == .repetitions ? Int(workoutSets.first?.repetitions ?? 0) :
                convertWeightForDisplaying(workoutSets.first?.weight ?? 0)
    }
    
    func weightValues() -> [Double] {
        var result = [Double]()
        for workout in workoutsWithExercise {
            let setGroupsWithExercise = (workout.setGroups?.array as? [WorkoutSetGroup] ?? .emptyList).filter { $0.exercise == exercise }
            let maxValue = (setGroupsWithExercise.map { ($0.sets?.array as? [WorkoutSet] ?? .emptyList).map { selectedAttribute == .repetitions ? $0.repetitions : $0.weight } }).reduce([], +).max()
            if let maxValue = maxValue, maxValue > 0 {
                result.append(Double(selectedAttribute == .weight ? convertWeightForDisplaying(maxValue) : Int(maxValue)))
            }
        }
        result = result.count == 0 ? [0, 0] : result.count == 1 ? [0, result[0]] : result
        return result
    }
    
    func getGraphYValues(for attribute: WorkoutSet.Attribute) -> [Int] {
        let selectedCalendarComponent = attribute == .repetitions ? selectedCalendarComponentForRepetitions : selectedCalendarComponentForWeight
        let numberOfValues = numberOfValues(for: selectedCalendarComponent)
        var result = [Int](repeating: 0, count: numberOfValues)
        for i in 0..<numberOfValues {
            if let iteratedDay = Calendar.current.date(byAdding: selectedCalendarComponent, value: -i, to: Date()) {
                for workoutSet in  exercise.sets {
                    if let setDate = workoutSet.workout?.date {
                        if Calendar.current.isDate(setDate, equalTo: iteratedDay, toGranularity: selectedCalendarComponent) {
                            switch attribute {
                            case .repetitions: result[i] = max(result[i], Int(workoutSet.repetitions))
                            case .weight: result[i] = max(result[i], convertWeightForDisplaying(workoutSet.weight))
                            case .time: continue
                            }
                        }
                    }
                }
            }
        }
        return result.reversed()
    }
    
    func getGraphXValues(for attribute: WorkoutSet.Attribute) -> [String] {
        var result = [String]()
        let selectedCalendarComponent = attribute == .repetitions ? selectedCalendarComponentForRepetitions : selectedCalendarComponentForWeight
        for i in 0..<numberOfValues(for: selectedCalendarComponent) {
            if let iteratedDay = Calendar.current.date(byAdding: selectedCalendarComponent, value: -i, to: Date()) {
                result.append(getFirstDayString(in: selectedCalendarComponent, for: iteratedDay))
            }
        }
        return result.reversed()
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
        default: return 5
        }
    }
    
}
