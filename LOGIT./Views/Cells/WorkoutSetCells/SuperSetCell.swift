//
//  SuperSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.05.22.
//

import SwiftUI

struct SuperSetCell: View {
        
    // MARK: - Environment
    
    @Environment(\.setWorkoutEndDate) var setWorkoutEndDate: (Date) -> Void
    @Environment(\.workoutSetTemplateSetDictionary) var workoutSetTemplateSetDictionary: [WorkoutSet:TemplateSet]
    @EnvironmentObject var database: Database
    
    // MARK: - Parameters
    
    @ObservedObject var superSet: SuperSet
    @Binding var focusedIntegerFieldIndex: IntegerField.Index?
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if let indexInWorkout = indexInWorkout {
                HStack {
                    Text("1")
                        .foregroundColor(.secondaryLabel)
                        .font(.footnote)
                    IntegerField(
                        placeholder: repetitionsPlaceholder(for: superSet).first!,
                        value: superSet.repetitionsFirstExercise,
                        setValue: {
                            superSet.repetitionsFirstExercise = $0
                            setWorkoutEndDate(.now)
                        },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: indexInWorkout,
                            secondary: 0,
                            tertiary: 0
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                        unit: NSLocalizedString("reps", comment: "")
                    )
                    IntegerField(
                        placeholder: weightsPlaceholder(for: superSet).first!,
                        value: Int64(convertWeightForDisplaying(superSet.weightFirstExercise)),
                        setValue: {
                            superSet.weightFirstExercise = convertWeightForStoring($0)
                            setWorkoutEndDate(.now)
                        },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: indexInWorkout,
                            secondary: 0,
                            tertiary: 1
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                        unit: WeightUnit.used.rawValue
                    )
                }
                HStack {
                    Text("2")
                        .foregroundColor(.secondaryLabel)
                        .font(.footnote)
                    IntegerField(
                        placeholder: repetitionsPlaceholder(for: superSet).second!,
                        value: superSet.repetitionsSecondExercise,
                        setValue: {
                            superSet.repetitionsSecondExercise = $0
                            setWorkoutEndDate(.now)
                        },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: indexInWorkout,
                            secondary: 1,
                            tertiary: 0
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                        unit: NSLocalizedString("reps", comment: "")
                    )
                    IntegerField(
                        placeholder: weightsPlaceholder(for: superSet).second!,
                        value: Int64(convertWeightForDisplaying(superSet.weightSecondExercise)),
                        setValue: {
                            superSet.weightSecondExercise = convertWeightForStoring($0)
                            setWorkoutEndDate(.now)
                        },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: indexInWorkout,
                            secondary: 1,
                            tertiary: 1
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                        unit: WeightUnit.used.rawValue
                    )
                }.accentColor(superSet.secondaryExercise?.muscleGroup?.color)
            }
        }
    }
    
    // MARK: - Supporting Methods
    
    private var indexInWorkout: Int? {
        superSet.workout?.sets.firstIndex(of: superSet)
    }
    
    private func repetitionsPlaceholder(for superSet: SuperSet) -> [Int64] {
        guard let templateSuperSet = workoutSetTemplateSetDictionary[superSet] as? TemplateSuperSet else { return [0, 0] }
        return [templateSuperSet.repetitionsFirstExercise, templateSuperSet.repetitionsSecondExercise]
            .map { $0 }
    }
    
    private func weightsPlaceholder(for superSet: SuperSet) -> [Int64] {
        guard let templateSuperSet = workoutSetTemplateSetDictionary[superSet] as? TemplateSuperSet else { return [0, 0] }
        return [templateSuperSet.weightFirstExercise, templateSuperSet.weightSecondExercise]
            .map { Int64(convertWeightForDisplaying($0)) }
    }
    
}
