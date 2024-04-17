//
//  WorkoutObserver.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 15.04.24.
//

import Foundation
import CoreData
import Combine

class EntityObserver {
    
    private var objectCancellables: [NSManagedObjectID: Set<AnyCancellable>] = [:]
    
    
    func onWorkoutChanged(workout: Workout, _ action: @escaping () -> Void) {
        subscribe(to: workout.publisher(for: \.name), action: action, object: workout)
        subscribe(to: workout.publisher(for: \.date), action: action, object: workout)
        subscribe(to: workout.publisher(for: \.endDate), action: action, object: workout)
        subscribe(to: workout.publisher(for: \.template), action: action, object: workout)
        subscribe(to: workout.publisher(for: \.setGroupOrder), action: action, object: workout)
        
        workout.setGroups.forEach { setGroup in
            onWorkoutSetGroupChanged(setGroup: setGroup, action)
        }
    }
    
    func onWorkoutSetGroupChanged(setGroup: WorkoutSetGroup, _ action: @escaping () -> Void) {
        subscribe(to: setGroup.publisher(for: \.exerciseOrder), action: action, object: setGroup)
        subscribe(to: setGroup.publisher(for: \.setOrder), action: action, object: setGroup)
        
        setGroup.sets.forEach { workoutSet in
            onWorkoutSetChanged(workoutSet: workoutSet, action)
        }
    }

    func onWorkoutSetChanged(workoutSet: WorkoutSet, _ action: @escaping () -> Void) {
        switch workoutSet {
        case let standardSet as StandardSet:
            subscribe(to: standardSet.publisher(for: \.weight), action: action, object: standardSet)
            subscribe(to: standardSet.publisher(for: \.repetitions), action: action, object: standardSet)
        case let superSet as SuperSet:
            subscribe(to: superSet.publisher(for: \.weightFirstExercise), action: action, object: superSet)
            subscribe(to: superSet.publisher(for: \.repetitionsFirstExercise), action: action, object: superSet)
            subscribe(to: superSet.publisher(for: \.weightSecondExercise), action: action, object: superSet)
            subscribe(to: superSet.publisher(for: \.repetitionsSecondExercise), action: action, object: superSet)
        case let dropSet as DropSet:
            subscribe(to: dropSet.publisher(for: \.repetitions), action: action, object: dropSet)
            subscribe(to: dropSet.publisher(for: \.weights), action: action, object: dropSet)
        default:
            break
        }
    }

    func unsubscribeObject(_ object: NSManagedObject) {
        switch object {
        case let workout as Workout:
            workout.setGroups.forEach { unsubscribeObject($0) }
        case let setGroup as WorkoutSetGroup:
            setGroup.sets.forEach { unsubscribeObject($0) }
        default: break
        }
        
        objectCancellables[object.objectID]?.forEach { $0.cancel() }
        objectCancellables.removeValue(forKey: object.objectID)
    }
    
    // MARK: - Private Methods
    
    private func subscribe<T: Publisher>(
        to publisher: T,
        action: @escaping () -> Void,
        object: NSManagedObject
    ) where T.Output: Any, T.Failure: Error {
        let cancellable = publisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .catch { error -> Empty<T.Output, Never> in
                // Here you can handle the error if needed
                print("Error: \(error)")
                return Empty(completeImmediately: false)
            }
            .sink(receiveValue: { _ in action() })

        if objectCancellables[object.objectID] == nil {
            objectCancellables[object.objectID] = Set<AnyCancellable>()
        }
        objectCancellables[object.objectID]?.insert(cancellable)
    }
    
}
