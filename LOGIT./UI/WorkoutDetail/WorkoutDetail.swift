//
//  WorkoutDetail.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

final class WorkoutDetail: ViewModel {
    
    @Published var workoutID: NSManagedObjectID
        
    init(workoutID: NSManagedObjectID) {
        self.workoutID = workoutID
    }
    
    var workout: Workout {
        get {
            database.object(with: workoutID) as? Workout ?? Workout()
        }
        set {
            let workout = database.object(with: workoutID) as! Workout
            workout.setGroups = newValue.setGroups
            workout.name = newValue.name
            database.save()
        }
    }
    
    var setGroups: [WorkoutSetGroup] {
        workout.setGroups
    }
    
    var workoutsFromTemplate: [Workout] {
        workout.template?.workouts ?? .emptyList
    }
    
    var workoutTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: workout.date ?? Date())
    }
    
    var workoutDateString: String {
        workout.date?.description(.long) ?? ""
    }
    
    var workoutDurationString: String {
        guard let start = workout.date, let end = workout.endDate else { return "0:00" }
        let hours = Calendar.current.dateComponents([.hour], from: start, to: end).hour ?? 0
        let minutes = Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0
        return "\(hours):\(minutes < 10 ? "0" : "")\(minutes)"
    }
            
    func deleteWorkout() {
        database.delete(workout, saveContext: true)
    }
    
}
