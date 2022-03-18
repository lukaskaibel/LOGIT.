//
//  WorkoutDetail.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

final class WorkoutDetail: ObservableObject {
    
    @Published var workoutID: NSManagedObjectID
    @Published var selectedSet: WorkoutSet? = nil
    @Published var selectedAttribute: WorkoutSet.Attribute? = nil
    
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
    
    var numberOfSets: Int {
        workout.numberOfSets
    }
    
    var workoutDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: workout.date ?? Date())
    }
    
    var textFieldString: String {
        get {
            if let selectedSet = selectedSet, let selectedAttribute = selectedAttribute {
                switch selectedAttribute {
                case .repetitions: return String(selectedSet.repetitions)
                case .weight: return String(selectedSet.weight)
                case .time: return String(selectedSet.time)
                }
            } else {
                return ""
            }
        }
        set {
            switch selectedAttribute {
            case .repetitions: selectedSet?.repetitions = Int64(newValue) ?? 0
            case .weight: selectedSet?.weight = Int64(newValue) ?? 0 
            case .time: selectedSet?.time = Int64(newValue) ?? 0
            default: break
            }
        }
    }
    
    var textFieldShouldShow: Bool {
        return selectedSet != nil && selectedAttribute != nil
    }
    
    func toggleFavorite(for exercise: Exercise) {
        do {
            exercise.isFavorite.toggle()
            try context.save()
            objectWillChange.send()
        } catch {
            fatalError("Couldn't save context")
        }
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
