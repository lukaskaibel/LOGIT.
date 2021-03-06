//
//  Home.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 27.12.21.
//

import SwiftUI
import CoreData


final class Home: ObservableObject {
    
    @Published var workouts: [Workout]
    @Published var goalPerWeek: Int = 3
    
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.workouts = [Workout]()
        NotificationCenter.default.addObserver(self, selector: #selector(contextChanged), name: .NSManagedObjectContextObjectsDidChange, object: context)
        updateWorkouts()
    }
    
    var recentWorkouts: [Workout] {
        Array(workouts.prefix(10))
    }
    
    func delete(workout: Workout) {
        do {
            context.delete(workout)
            try context.save()
            updateWorkouts()
            objectWillChange.send()
        } catch {
            fatalError("Error deleting workout: \(error)")
        }
    }
    
    func updateWorkouts() {
        do {
            let request = Workout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            try self.workouts = context.fetch(request)
        } catch {
            fatalError("Error fetching workouts: \(error)")
        }
    }
    
    func workoutsPerWeek(for numberOfWeeks: Int) -> [Int] {
        var result = [Int](repeating: 0, count: numberOfWeeks)
        for i in 0..<numberOfWeeks {
            if let iteratedDay = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) {
                for workout in workouts {
                    if let workoutDate = workout.date {
                        if Calendar.current.isDate(workoutDate, equalTo: iteratedDay, toGranularity: .weekOfYear) {
                            result[i] += 1
                        }
                    }
                }
            }
        }
        return result
    }
    
    func averageWorkoutsPerWeek(for numberOfWeeks: Int) -> Int {
        let nonZeroWorkoutWeeks = workoutsPerWeek(for: numberOfWeeksInAnalysis).filter { $0 > 0}
        if nonZeroWorkoutWeeks.count == 0 {
            return 0
        } else {
            return nonZeroWorkoutWeeks.reduce(0, +) / nonZeroWorkoutWeeks.count
        }
    }
    
    func barColorsForWeeks() -> [Color] {
        workoutsPerWeek(for: numberOfWeeksInAnalysis).map { $0 >= goalPerWeek ? .accentColor : .accentColor }
    }
    
    func getWeeksString() -> [String] {
        var result = [String]()
        for i in 0..<numberOfWeeksInAnalysis {
            if let iteratedDay = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) {
                result.append(getFirstDayOfWeekString(for: iteratedDay))
            }
        }
        return result
    }
    
    func getFirstDayOfWeekString(for date: Date) -> String {
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter.string(from: firstDayOfWeek)
    }
    
    //MARK: Constants
    
    let numberOfWeeksInAnalysis = 5
    
    
    @objc private func contextChanged() {
        updateWorkouts()
    }
    
}
