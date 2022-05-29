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
        database.fetch(WorkoutSet.self)
            .compactMap { $0 as? WorkoutSet }
            .filter { $0.exercise == exercise }
            .map { workoutSet in
                return attribute == .repetitions ? workoutSet.maxRepetitions : workoutSet.maxWeight
            }
            .max() ?? 0
    }
        
    func getGraphYValues(for attribute: WorkoutSet.Attribute) -> [Int] {
        let selectedCalendarComponent = attribute == .repetitions ? selectedCalendarComponentForRepetitions : selectedCalendarComponentForWeight
        let numberOfValues = numberOfValues(for: selectedCalendarComponent)
        var result = [Int](repeating: 0, count: numberOfValues)
        for i in 0..<numberOfValues {
            guard let iteratedDay = Calendar.current.date(byAdding: selectedCalendarComponent,
                                                          value: -i,
                                                          to: Date()) else { continue }
            for workoutSet in exercise.sets {
                guard let setDate = workoutSet.setGroup?.workout?.date,
                        Calendar.current.isDate(setDate,
                                                equalTo: iteratedDay,
                                                toGranularity: selectedCalendarComponent) else { continue }
                switch attribute {
                case .repetitions: result[i] = max(result[i], Int(workoutSet.maxRepetitions))
                case .weight: result[i] = max(result[i], convertWeightForDisplaying(workoutSet.maxWeight))
                }
            }
        }
        return result.reversed()
    }
    
    func getGraphXValues(for attribute: WorkoutSet.Attribute) -> [String] {
        var result = [String]()
        let selectedCalendarComponent = attribute == .repetitions ? selectedCalendarComponentForRepetitions : selectedCalendarComponentForWeight
        for i in 0..<numberOfValues(for: selectedCalendarComponent) {
            guard let iteratedDay = Calendar.current.date(byAdding: selectedCalendarComponent, value: -i, to: Date()) else { continue }
            result.append(getFirstDayString(in: selectedCalendarComponent, for: iteratedDay))
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
