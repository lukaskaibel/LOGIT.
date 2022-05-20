//
//  Database+Entity Creation.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 16.04.22.
//

import Foundation

extension Database {
    
    //MARK: - Normal Entitiy Creation
    
    @discardableResult
    func newWorkout(name: String = "",
                    date: Date = Date(),
                    setGroups: [WorkoutSetGroup] = [WorkoutSetGroup]()) -> Workout {
        let workout = Workout(context: context)
        workout.name = name
        workout.date = date
        workout.setGroups = NSOrderedSet(array: setGroups)
        return workout
    }
    
    @discardableResult
    func newWorkoutSetGroup(sets: [WorkoutSet]? = nil,
                            createFirstSetAutomatically: Bool = true,
                            exercise: Exercise? = nil,
                            workout: Workout? = nil) -> WorkoutSetGroup {
        let setGroup = WorkoutSetGroup(context: context)
        if let sets = sets, !sets.isEmpty {
            setGroup.sets = NSOrderedSet(array: sets)
        } else if createFirstSetAutomatically {
            newStandardSet(setGroup: setGroup)
        }
        setGroup.exercise = exercise
        setGroup.workout = workout
        return setGroup
    }
    
    @discardableResult
    func newStandardSet(repetitions: Int = 0,
                       weight: Int = 0,
                       setGroup: WorkoutSetGroup? = nil) -> StandardSet {
        let standardSet = StandardSet(context: context)
        standardSet.repetitions = Int64(repetitions)
        standardSet.weight = Int64(weight)
        standardSet.setGroup = setGroup
        return standardSet
    }
    
    @discardableResult
    func newDropSet(repetitions: [Int] = [0],
                    weights: [Int] = [0],
                    setGroup: WorkoutSetGroup? = nil) -> DropSet {
        let dropSet = DropSet(context: context)
        dropSet.repetitions = repetitions.map { Int64($0) }
        dropSet.weights = weights.map { Int64($0) }
        dropSet.setGroup = setGroup
        return dropSet
    }
    
    @discardableResult
    func newDropSet(from templateDropSet: TemplateDropSet,
                    setGroup: WorkoutSetGroup? = nil) -> DropSet {
        let dropSet = DropSet(context: context)
        dropSet.repetitions = Array(repeatElement(0, count: templateDropSet.repetitions?.count ?? 0))
        dropSet.weights = Array(repeating: 0, count: templateDropSet.weights?.count ?? 0)
        dropSet.setGroup = setGroup
        return dropSet
    }
    
    @discardableResult
    func newExercise(name: String = "",
                     muscleGroup: MuscleGroup? = nil,
                     setGroups: [WorkoutSetGroup]? = nil) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.name = name
        exercise.muscleGroup = muscleGroup
        if let setGroups = setGroups {
            exercise.setGroups = NSOrderedSet(array: setGroups)
        }
        return exercise
    }
    
    //MARK: - Template Entitiy Creation
    
    @discardableResult
    func newTemplateWorkout(name: String = "",
                            setGroups: [TemplateWorkoutSetGroup] = [TemplateWorkoutSetGroup]()) -> TemplateWorkout {
        let templateWorkout = TemplateWorkout(context: context)
        templateWorkout.name = name
        templateWorkout.creationDate = Date.now
        templateWorkout.setGroups = NSOrderedSet(array: setGroups)
        return templateWorkout
    }
    
    @discardableResult
    func newTemplateWorkout(from workout: Workout) -> TemplateWorkout {
        let template = newTemplateWorkout(name: workout.name ?? "")
        workout.template = template
        for setGroup in workout.setGroups?.array as? [WorkoutSetGroup] ?? .emptyList {
            let templateSetGroup = newTemplateWorkoutSetGroup(createFirstSetAutomatically: false,
                                                              exercise: setGroup.exercise,
                                                              templateWorkout: template)
            for workoutSet in setGroup.sets?.array as? [WorkoutSet] ?? .emptyList {
                newTemplateSet(from: workoutSet, templateSetGroup: templateSetGroup)
            }
        }
        return template
    }
    
    @discardableResult
    func newTemplateWorkoutSetGroup(templateSets: [TemplateSet]? = nil,
                                    createFirstSetAutomatically: Bool = true,
                                    exercise: Exercise? = nil,
                                    templateWorkout: TemplateWorkout? = nil) -> TemplateWorkoutSetGroup {
        let templateSetGroup = TemplateWorkoutSetGroup(context: context)
        if let templateSets = templateSets, !templateSets.isEmpty {
            templateSetGroup.sets = NSOrderedSet(array: templateSets)
        } else if createFirstSetAutomatically {
            newTemplateStandardSet(setGroup: templateSetGroup)
        }
        templateSetGroup.exercise = exercise
        templateSetGroup.workout = templateWorkout
        return templateSetGroup
    }
    
    @discardableResult
    func newTemplateSet(from workoutSet: WorkoutSet,
                        templateSetGroup: TemplateWorkoutSetGroup? = nil) -> TemplateSet {
        if let standardSet = workoutSet as? StandardSet {
            let templateStandardSet = TemplateStandardSet(context: context)
            templateStandardSet.repetitions = standardSet.repetitions
            templateStandardSet.weight = standardSet.weight
            templateStandardSet.setGroup = templateSetGroup
            return templateStandardSet

        } else if let dropSet = workoutSet as? DropSet {
            let templateDropSet = TemplateDropSet(context: context)
            templateDropSet.repetitions = dropSet.repetitions
            templateDropSet.weights = dropSet.weights
            templateDropSet.setGroup = templateSetGroup
            return templateDropSet
        } else {
            fatalError("Not implemented for SuperSet")
        }
    }
    
    @discardableResult
    func newTemplateStandardSet(repetitions: Int = 0,
                               weight: Int = 0,
                               setGroup: TemplateWorkoutSetGroup? = nil) -> TemplateStandardSet {
        let templateWorkoutSet = TemplateStandardSet(context: context)
        templateWorkoutSet.repetitions = Int64(repetitions)
        templateWorkoutSet.weight = Int64(weight)
        templateWorkoutSet.setGroup = setGroup
        return templateWorkoutSet
    }
        
    @discardableResult
    func newTemplateDropSet(repetitions: [Int] = [0],
                            weights: [Int] = [0],
                            templateSetGroup: TemplateWorkoutSetGroup? = nil) -> TemplateDropSet {
        let templateDropSet = TemplateDropSet(context: context)
        templateDropSet.repetitions = repetitions.map { Int64($0) }
        templateDropSet.weights = weights.map { Int64($0) }
        templateDropSet.setGroup = templateSetGroup
        return templateDropSet
    }

    
}
