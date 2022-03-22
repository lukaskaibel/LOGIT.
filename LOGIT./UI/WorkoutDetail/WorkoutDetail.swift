//
//  WorkoutDetail.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

final class WorkoutDetail: ObservableObject {
    
    @Published var workoutID: NSManagedObjectID
    
    private var context: NSManagedObjectContext
    private var database = Database.shared
    
    init(context: NSManagedObjectContext, workoutID: NSManagedObjectID) {
        self.context = context
        self.workoutID = workoutID
    }
    
    var workout: Workout {
        get {
            if let workout = context.object(with: workoutID) as? Workout {
                return workout
            } else {
                return Workout()
            }
        }
        set {
            do {
                let workout = context.object(with: workoutID) as! Workout
                workout.setGroups = newValue.setGroups
                workout.name = newValue.name
                try context.save()
            } catch {
                fatalError("Error while saving context on workout change")
            }
        }
    }
    
    var setGroups: [WorkoutSetGroup] {
        workout.setGroups?.array as? [WorkoutSetGroup] ?? .emptyList
    }
    
    var workoutTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: workout.date ?? Date())
    }
    
    var workoutDateString: String {
        workout.date?.description(.long) ?? ""
    }
    
    func remove(_ setGroup: WorkoutSetGroup) {
        database.delete(setGroup)
    }
    
    func deleteWorkout() {
        do {
            context.delete(workout)
            try context.save()
        } catch {
            fatalError("Deleting workout failed")
        }
    }
    
}
