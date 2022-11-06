//
//  Database+Entity Creation.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 16.04.22.
//

import Foundation

extension Database {
    
    // MARK: - Normal Entitiy Creation
    
    @discardableResult
    func newWorkout(name: String = "",
                    date: Date = Date(),
                    setGroups: [WorkoutSetGroup] = [WorkoutSetGroup]()) -> Workout {
        let workout = Workout(context: context)
        workout.name = name
        workout.date = date
        workout.setGroups = setGroups
        return workout
    }
    
    @discardableResult
    func newWorkoutSetGroup(sets: [WorkoutSet] = [],
                            createFirstSetAutomatically: Bool = true,
                            exercise: Exercise? = nil,
                            workout: Workout? = nil) -> WorkoutSetGroup {
        let setGroup = WorkoutSetGroup(context: context)
        setGroup.id = UUID()
        if !sets.isEmpty {
            setGroup.sets = sets
        } else if createFirstSetAutomatically {
            newStandardSet(setGroup: setGroup)
        }
        exercise?.setGroups.append(setGroup)
        if let exercise = exercise {
            setGroup.exerciseOrder = [exercise.id!]
        }
        workout?.setGroups.append(setGroup)
        return setGroup
    }
    
    @discardableResult
    func newStandardSet(repetitions: Int = 0,
                       weight: Int = 0,
                       setGroup: WorkoutSetGroup? = nil) -> StandardSet {
        let standardSet = StandardSet(context: context)
        standardSet.id = UUID()
        standardSet.repetitions = Int64(repetitions)
        standardSet.weight = Int64(weight)
        setGroup?.sets.append(standardSet)
        return standardSet
    }
    
    @discardableResult
    func newDropSet(repetitions: [Int] = [0],
                    weights: [Int] = [0],
                    setGroup: WorkoutSetGroup? = nil) -> DropSet {
        let dropSet = DropSet(context: context)
        dropSet.id = UUID()
        dropSet.repetitions = repetitions.map { Int64($0) }
        dropSet.weights = weights.map { Int64($0) }
        setGroup?.sets.append(dropSet)
        return dropSet
    }
    
    @discardableResult
    func newDropSet(from templateDropSet: TemplateDropSet,
                    setGroup: WorkoutSetGroup? = nil) -> DropSet {
        return newDropSet(repetitions: Array(repeatElement(0, count: templateDropSet.repetitions?.count ?? 0)),
                          weights: Array(repeating: 0, count: templateDropSet.weights?.count ?? 0),
                          setGroup: setGroup)
    }
    
    @discardableResult
    func newSuperSet(repetitionsFirstExercise: Int = 0,
                     repeptitionsSecondExercise: Int = 0,
                     weightFirstExercise: Int = 0,
                     weightSecondExercise: Int = 0,
                     setGroup: WorkoutSetGroup? = nil) -> SuperSet {
        let superSet = SuperSet(context: context)
        superSet.id = UUID()
        superSet.repetitionsFirstExercise = Int64(repetitionsFirstExercise)
        superSet.repetitionsSecondExercise = Int64(repeptitionsSecondExercise)
        superSet.weightFirstExercise = Int64(weightFirstExercise)
        superSet.weightSecondExercise = Int64(weightSecondExercise)
        setGroup?.sets.append(superSet)
        return superSet
    }
    
    @discardableResult
    func newSuperSet(from templateSuperSet: TemplateSuperSet,
                     setGroup: WorkoutSetGroup? = nil) -> SuperSet {
        let superSet = newSuperSet(setGroup: setGroup)
        setGroup?.secondaryExercise = templateSuperSet.secondaryExercise
        return superSet
    }
    
    @discardableResult
    func newExercise(name: String = "",
                     muscleGroup: MuscleGroup? = nil,
                     setGroups: [WorkoutSetGroup] = []) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.muscleGroup = muscleGroup
        setGroups.forEach { $0.exercise = exercise }
        return exercise
    }
    
    // MARK: - Template Entitiy Creation
    
    @discardableResult
    func newTemplateWorkout(name: String = "",
                            setGroups: [TemplateWorkoutSetGroup] = [TemplateWorkoutSetGroup]()) -> TemplateWorkout {
        let templateWorkout = TemplateWorkout(context: context)
        templateWorkout.name = name
        templateWorkout.creationDate = Date.now
        templateWorkout.setGroups = setGroups
        return templateWorkout
    }
    
    @discardableResult
    func newTemplateWorkout(from workout: Workout) -> TemplateWorkout {
        let template = newTemplateWorkout(name: workout.name ?? "")
        workout.template = template
        for setGroup in workout.setGroups {
            let templateSetGroup = newTemplateWorkoutSetGroup(createFirstSetAutomatically: false,
                                                              exercise: setGroup.exercise,
                                                              templateWorkout: template)
            for workoutSet in setGroup.sets {
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
        templateSetGroup.id = UUID()
        if let templateSets = templateSets, !templateSets.isEmpty {
            templateSetGroup.sets = templateSets
        } else if createFirstSetAutomatically {
            newTemplateStandardSet(setGroup: templateSetGroup)
        }
        exercise?.templateSetGroups.append(templateSetGroup)
        if let exercise = exercise {
            templateSetGroup.exerciseOrder = [exercise.id!]
        }
        templateWorkout?.setGroups.append(templateSetGroup)
        return templateSetGroup
    }
    
    @discardableResult
    func newTemplateSet(from workoutSet: WorkoutSet,
                        templateSetGroup: TemplateWorkoutSetGroup? = nil) -> TemplateSet {
        if let standardSet = workoutSet as? StandardSet {
            let templateStandardSet = TemplateStandardSet(context: context)
            templateStandardSet.id = UUID()
            templateStandardSet.repetitions = standardSet.repetitions
            templateStandardSet.weight = standardSet.weight
            templateSetGroup?.sets.append(templateStandardSet)
            return templateStandardSet

        } else if let dropSet = workoutSet as? DropSet {
            let templateDropSet = TemplateDropSet(context: context)
            templateDropSet.id = UUID()
            templateDropSet.repetitions = dropSet.repetitions
            templateDropSet.weights = dropSet.weights
            templateSetGroup?.sets.append(templateDropSet)
            return templateDropSet
        } else if let superSet = workoutSet as? SuperSet {
            let templateSuperSet = TemplateSuperSet(context: context)
            templateSuperSet.id = UUID()
            templateSuperSet.repetitionsFirstExercise = superSet.repetitionsFirstExercise
            templateSuperSet.repetitionsSecondExercise = superSet.repetitionsSecondExercise
            templateSuperSet.weightFirstExercise = superSet.weightFirstExercise
            templateSuperSet.weightSecondExercise = superSet.weightSecondExercise
            templateSetGroup?.sets.append(templateSuperSet)
            templateSetGroup?.secondaryExercise = superSet.secondaryExercise
            return templateSuperSet
        } else {
            fatalError("Database: Not implemented for variation of TemplateSet.")
        }
    }
    
    @discardableResult
    func newTemplateStandardSet(repetitions: Int = 0,
                                weight: Int = 0,
                                setGroup: TemplateWorkoutSetGroup? = nil) -> TemplateStandardSet {
        let templateWorkoutSet = TemplateStandardSet(context: context)
        templateWorkoutSet.id = UUID()
        templateWorkoutSet.repetitions = Int64(repetitions)
        templateWorkoutSet.weight = Int64(weight)
        setGroup?.sets.append(templateWorkoutSet)
        return templateWorkoutSet
    }
        
    @discardableResult
    func newTemplateDropSet(repetitions: [Int] = [0],
                            weights: [Int] = [0],
                            templateSetGroup: TemplateWorkoutSetGroup? = nil) -> TemplateDropSet {
        let templateDropSet = TemplateDropSet(context: context)
        templateDropSet.id = UUID()
        templateDropSet.repetitions = repetitions.map { Int64($0) }
        templateDropSet.weights = weights.map { Int64($0) }
        templateSetGroup?.sets.append(templateDropSet)
        return templateDropSet
    }

    @discardableResult
    func newTemplateSuperSet(repetitionsFirstExercise: Int = 0,
                             repetitionsSecondExercise: Int = 0,
                             weightFirstExercise: Int = 0,
                             weightSecondExercise: Int = 0,
                             setGroup: TemplateWorkoutSetGroup? = nil) -> TemplateSuperSet {
        let templateSuperSet = TemplateSuperSet(context: context)
        templateSuperSet.id = UUID()
        templateSuperSet.repetitionsFirstExercise = Int64(repetitionsFirstExercise)
        templateSuperSet.repetitionsSecondExercise = Int64(repetitionsSecondExercise)
        templateSuperSet.weightFirstExercise = Int64(weightFirstExercise)
        templateSuperSet.weightSecondExercise = Int64(weightSecondExercise)
        setGroup?.sets.append(templateSuperSet)
        return templateSuperSet
    }
    
}