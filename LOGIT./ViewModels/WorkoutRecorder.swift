//
//  WorkoutRecorder.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 02.03.24.
//

import Foundation
import OSLog

final class WorkoutRecorder: ObservableObject {
    
    // MARK: - Static
    
    private static let logger = Logger(subsystem: ".com.lukaskbl.LOGIT", category: "WorkoutRecorder")
    
    // MARK: - Public Variables
    
    @Published var workout: Workout?
    
    // MARK: - Private Variables
    
    private let database: Database
    private var workoutSetTemplateSetDictionary = [WorkoutSet: TemplateSet]()
    
    // MARK: - Init
    
    init(database: Database) {
        self.database = database
    }
    
    // MARK: - Public Methods
    
    func startWorkout(from template: Template? = nil) {
        workout = database.newWorkout()
        if let template = template {
            template.workouts.append(workout!)
            workout!.name = template.name
            for templateSetGroup in template.setGroups {
                let setGroup = database.newWorkoutSetGroup(
                    createFirstSetAutomatically: false,
                    exercise: templateSetGroup.exercise,
                    workout: workout
                )
                templateSetGroup.sets
                    .forEach { templateSet in
                        if let templateStandardSet = templateSet as? TemplateStandardSet {
                            let standardSet = database.newStandardSet(setGroup: setGroup)
                            workoutSetTemplateSetDictionary[standardSet] = templateStandardSet
                        } else if let templateDropSet = templateSet as? TemplateDropSet {
                            let dropSet = database.newDropSet(from: templateDropSet, setGroup: setGroup)
                            workoutSetTemplateSetDictionary[dropSet] = templateDropSet
                        } else if let templateSuperSet = templateSet as? TemplateSuperSet {
                            let superSet = database.newSuperSet(
                                from: templateSuperSet,
                                setGroup: setGroup
                            )
                            workoutSetTemplateSetDictionary[superSet] = templateSuperSet
                        }
                    }
            }
        }
        database.refreshObjects()
    }
    
    func saveWorkout() {
        guard let workout = workout else {
            Self.logger.warning("Attempted to save empty workout")
            return
        }
        if workout.name?.isEmpty ?? true {
            workout.name = Workout.getStandardName(for: workout.date!)
        }
        workout.setGroups.forEach {
            if $0.setType == .superSet && $0.secondaryExercise == nil {
                database.convertSetGroupToStandardSets($0)
            }
        }
        
        workout.exercises.forEach { database.unflagAsTemporary($0) }
        database.deleteAllTemporaryObjects()
        
        workout.sets.filter({ !$0.hasEntry }).forEach { database.delete($0) }
        if workout.isEmpty {
            database.delete(workout, saveContext: true)
        }
        
        self.workout = nil
        database.save()
    }
    
    func discardWorkout() {
        guard let workout = workout else {
            Self.logger.warning("Attempted to discard empty workout")
            return
        }
        database.deleteAllTemporaryObjects()
        database.refreshObjects()

        workout.sets.filter({ !$0.hasEntry }).forEach { database.delete($0) }
        self.workout = nil
        database.delete(workout, saveContext: true)
    }
    
    func addSetGroup(with exercise: Exercise) {
        database.newWorkoutSetGroup(
            createFirstSetAutomatically: true,
            exercise: exercise,
            workout: workout
        )
        objectWillChange.send()
    }
    
    func moveSetGroups(from source: IndexSet, to destination: Int) {
        workout?.setGroups.move(fromOffsets: source, toOffset: destination)
        objectWillChange.send()
    }
    
    func toggleSetCompleted(for workoutSet: WorkoutSet) {
        if let templateSet = workoutSetTemplateSetDictionary[workoutSet] {
            if workoutSet.hasEntry {
                workoutSet.clearEntries()
            } else {
                workoutSet.match(templateSet)
            }
            objectWillChange.send()
        }
    }
    
    func toggleCopyPrevious(for workoutSet: WorkoutSet) {
        if workoutSet.hasEntry {
            workoutSet.clearEntries()
        } else {
            guard let previousSet = workoutSet.previousSetInSetGroup else { return }
            workoutSet.match(previousSet)
        }
        objectWillChange.send()
    }
    
    func templateSet(for workoutSet: WorkoutSet) -> TemplateSet? {
        workoutSetTemplateSetDictionary[workoutSet]
    }
    
    
    /// Returns the next workout set to be executed. This is the first workout set, that has no workout set with entries after it.
    var nextPerformedWorkoutSet: WorkoutSet? {
        workout?.sets.reversed().reduce(nil, { $1.hasEntry ? $0 : $1 })
    }
    
}
