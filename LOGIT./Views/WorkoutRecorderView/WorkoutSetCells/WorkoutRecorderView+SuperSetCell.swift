//
//  WorkoutRecorderView+SuperSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func superSetCell(for superSet: SuperSet) -> some View {
        VStack {
            HStack {
                Text("1")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                IntegerField(
                    placeholder: repetitionsPlaceholder(for: superSet).first!,
                    value: superSet.repetitionsFirstExercise,
                    setValue: { superSet.repetitionsFirstExercise = $0; workout.endDate = .now },
                    maxDigits: 4,
                    index: IntegerField.Index(
                        primary: workout.sets.firstIndex(of: superSet)!,
                        secondary: 0,
                        tertiary: 0
                    ),
                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                )
                IntegerField(
                    placeholder: weightsPlaceholder(for: superSet).first!,
                    value: Int64(convertWeightForDisplaying(superSet.weightFirstExercise)),
                    setValue: { superSet.weightFirstExercise = $0; workout.endDate = .now },
                    maxDigits: 4,
                    index: IntegerField.Index(
                        primary: workout.sets.firstIndex(of: superSet)!,
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
                    setValue: { superSet.repetitionsSecondExercise = $0; workout.endDate = .now },
                    maxDigits: 4,
                    index: IntegerField.Index(
                        primary: workout.sets.firstIndex(of: superSet)!,
                        secondary: 1,
                        tertiary: 0
                    ),
                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                )
                IntegerField(
                    placeholder: weightsPlaceholder(for: superSet).second!,
                    value: Int64(convertWeightForDisplaying(superSet.weightSecondExercise)),
                    setValue: { superSet.weightSecondExercise = $0; workout.endDate = .now },
                    maxDigits: 4,
                    index: IntegerField.Index(
                        primary: workout.sets.firstIndex(of: superSet)!,
                        secondary: 1,
                        tertiary: 1
                    ),
                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                )
            }.accentColor(superSet.secondaryExercise?.muscleGroup?.color)
        }
    }
    
}
