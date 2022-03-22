//
//  ExerciseDetail.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.01.22.
//

import SwiftUI
import CoreData

final class ExerciseDetail: ObservableObject {
    
    @Published var selectedCalendarComponentForRepetitions: Calendar.Component = .weekOfYear
    @Published var selectedCalendarComponentForWeight: Calendar.Component = .weekOfYear
    
    private var context: NSManagedObjectContext
    private var database = Database.shared
    private var exerciseID: NSManagedObjectID
    
    init(context: NSManagedObjectContext, exerciseID: NSManagedObjectID) {
        self.context = context
        self.exerciseID = exerciseID
    }
    
    var exercise: Exercise {
        get {
            if let exercise = context.object(with: exerciseID) as? Exercise {
                return exercise
            } else {
                return Exercise()
            }
        }
        set {
            do {
                let exercise = context.object(with: exerciseID) as! Exercise
                exercise.name = newValue.name
                exercise.isFavorite = newValue.isFavorite
                try context.save()
            } catch {
                fatalError("Error while saving context on exercise change")
            }
        }
    }
    
    var sets: [WorkoutSet] {
        do {
            let request = WorkoutSet.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "setGroup.workout.date", ascending: false)]
            var workoutSets = try context.fetch(request)
            workoutSets = workoutSets.filter { $0.exercise == exercise }
            return workoutSets
        } catch {
            fatalError("Error fetching sets for exercise")
        }
    }
    
    func deleteExercise() {
        database.delete(exercise, saveContext: true)
    }
    
    func personalBest(for attribute: WorkoutSet.Attribute) -> Int {
        do {
            let request = WorkoutSet.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: attribute == .repetitions ? "repetitions" : "weight", ascending: false)]
            var workoutSets = try context.fetch(request)
            workoutSets = workoutSets.filter { $0.exercise == exercise }
            return attribute == .repetitions ? Int(workoutSets.first?.repetitions ?? 0) : convertWeightForDisplaying(workoutSets.first?.weight ?? 0)
        } catch {
            fatalError("Error fetching sets for exercise")
        }
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
    
    func toggleFavorite() {
        do {
            exercise.isFavorite.toggle()
            try context.save()
            objectWillChange.send()
        } catch {
            fatalError("Failed to save context")
        }
    }
    
    private func getFirstDayString(in component: Calendar.Component, for date: Date) -> String {
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        let formatter = DateFormatter()
        formatter.dateFormat = component == .weekOfYear ? "dd.MM." : component == .month ? "MMM" : "yyyy"
        return formatter.string(from: firstDayOfWeek)
    }
    
    private func numberOfValues(for calendarComponent: Calendar.Component) -> Int {
        switch calendarComponent {
        default: return 5
        }
    }
    
}
