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
    
    var workoutTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: workout.date ?? Date())
    }
    
    var workoutDateString: String {
        workout.date?.description(.long) ?? ""
    }
            
    func deleteWorkout() {
        database.delete(workout, saveContext: true)
    }
    
}
