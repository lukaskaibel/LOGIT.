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
            newWorkoutSet(setGroup: setGroup)
        }
        setGroup.exercise = exercise
        setGroup.workout = workout
        return setGroup
    }
    
    @discardableResult
    func newWorkoutSet(repetitions: Int = 0,
                       time: Int = 0,
                       weight: Int = 0,
                       setGroup: WorkoutSetGroup? = nil) -> WorkoutSet {
        let workoutSet = WorkoutSet(context: context)
        workoutSet.repetitions = Int64(repetitions)
        workoutSet.time = Int64(time)
        workoutSet.weight = Int64(weight)
        workoutSet.setGroup = setGroup
        return workoutSet
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
                newTemplateWorkoutSet(repetitions: Int(workoutSet.repetitions),
                                      weight: Int(workoutSet.weight),
                                      setGroup: templateSetGroup)
            }
        }
        return template
    }
    
    @discardableResult
    func newTemplateWorkoutSetGroup(templateSets: [TemplateWorkoutSet]? = nil,
                                    createFirstSetAutomatically: Bool = true,
                                    exercise: Exercise? = nil,
                                    templateWorkout: TemplateWorkout? = nil) -> TemplateWorkoutSetGroup {
        let templateSetGroup = TemplateWorkoutSetGroup(context: context)
        if let templateSets = templateSets, !templateSets.isEmpty {
            templateSetGroup.sets = NSOrderedSet(array: templateSets)
        } else if createFirstSetAutomatically {
            newTemplateWorkoutSet(setGroup: templateSetGroup)
        }
        templateSetGroup.exercise = exercise
        templateSetGroup.workout = templateWorkout
        return templateSetGroup
    }
    
    @discardableResult
    func newTemplateWorkoutSet(repetitions: Int = 0,
                               weight: Int = 0,
                               setGroup: TemplateWorkoutSetGroup? = nil) -> TemplateWorkoutSet {
        let templateWorkoutSet = TemplateWorkoutSet(context: context)
        templateWorkoutSet.repetitions = Int64(repetitions)
        templateWorkoutSet.weight = Int64(weight)
        templateWorkoutSet.setGroup = setGroup
        return templateWorkoutSet
    }

    
}
