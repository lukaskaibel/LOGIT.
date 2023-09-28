//
//  VolumeCalculator.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 28.09.23.
//

import Foundation

#if targetEnvironment(simulator)
private let database = Database.preview
#else
private let database = Database.shared
#endif
    
public func volume(for exercise: Exercise, per calendarComponent: Calendar.Component) -> [(Date, Int)] {
    let groupedWorkoutSets = database.getGroupedWorkoutsSets(with: exercise, in: calendarComponent)
    return Array(zip(
        groupedWorkoutSets.map { $0.first?.setGroup?.workout?.date ?? Date.distantPast },
        groupedWorkoutSets
            .map { groupedWorkoutSets in
                groupedWorkoutSets
                    .map { workoutSet in
                        if let standardSet = workoutSet as? StandardSet {
                            return Int(standardSet.repetitions * standardSet.weight)
                        }
                        if let dropSet = workoutSet as? DropSet, let repetitions = dropSet.repetitions, let weights = dropSet.weights {
                            return Int(zip(repetitions, weights).map(*).reduce(0, +))
                        }
                        if let superSet = workoutSet as? SuperSet {
                            if exercise == superSet.setGroup?.exercise {
                                return Int(superSet.repetitionsFirstExercise * superSet.weightFirstExercise)
                            }
                            if exercise == superSet.setGroup?.secondaryExercise {
                                return Int(superSet.repetitionsSecondExercise * superSet.weightSecondExercise)
                            }
                        }
                        return 0
                    }
                    .reduce(0, +)
            }
            .map { convertWeightForDisplaying($0) }
    ))
}

public func volume(per calendarComponent: Calendar.Component) -> [Int] {
    database.getGroupedWorkoutsSets(in: calendarComponent)
        .map { groupedWorkoutSets in
            groupedWorkoutSets
                .map { workoutSet in
                    if let standardSet = workoutSet as? StandardSet {
                        return Int(standardSet.repetitions * standardSet.weight)
                    }
                    if let dropSet = workoutSet as? DropSet, let repetitions = dropSet.repetitions, let weights = dropSet.weights {
                        return Int(zip(repetitions, weights).map(*).reduce(0, +))
                    }
                    if let superSet = workoutSet as? SuperSet {
                        return Int(superSet.repetitionsFirstExercise * superSet.weightFirstExercise) + Int(superSet.repetitionsSecondExercise * superSet.weightSecondExercise)
                    }
                    return 0
                }
                .reduce(0, +)
        }
        .map { convertWeightForDisplaying($0) }
}
