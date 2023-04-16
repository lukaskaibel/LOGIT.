//
//  WorkoutRecorderView+SuperSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal struct SuperSetCell: View {
        
        // MARK: - Environment
        
        @Environment(\.setWorkoutEndDate) var setWorkoutEndDate: (Date) -> Void
        @Environment(\.workoutSetTemplateSetDictionary) var workoutSetTemplateSetDictionary: [WorkoutSet:TemplateSet]
        @EnvironmentObject var database: Database
        
        // MARK: - Parameters
        
        @ObservedObject var superSet: SuperSet
        let indexInWorkout: Int
        @Binding var focusedIntegerFieldIndex: IntegerField.Index?
        
        // MARK: - Body
        
        var body: some View {
            VStack {
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
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                    )
                    IntegerField(
                        placeholder: weightsPlaceholder(for: superSet).first!,
                        value: Int64(convertWeightForDisplaying(superSet.weightFirstExercise)),
                        setValue: {
                            superSet.weightFirstExercise = $0
                            setWorkoutEndDate(.now)
                        },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: indexInWorkout,
                            secondary: 0,
                            tertiary: 1
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex
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
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                    )
                    IntegerField(
                        placeholder: weightsPlaceholder(for: superSet).second!,
                        value: Int64(convertWeightForDisplaying(superSet.weightSecondExercise)),
                        setValue: {
                            superSet.weightSecondExercise = $0
                            setWorkoutEndDate(.now)
                        },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: indexInWorkout,
                            secondary: 1,
                            tertiary: 1
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                    )
                }.accentColor(superSet.secondaryExercise?.muscleGroup?.color)
            }
        }
        
        // MARK: - Supporting Methods
        
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
    
}
