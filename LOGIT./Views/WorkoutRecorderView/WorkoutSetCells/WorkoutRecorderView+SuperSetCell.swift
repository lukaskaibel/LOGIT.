//
//  WorkoutRecorderView+SuperSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func SuperSetCell(for superSet: SuperSet) -> some View {
        VStack {
            HStack {
                Text("1")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                SetEntryEditor(repetitions: Binding(get: { superSet.repetitionsFirstExercise },
                                                         set: { superSet.repetitionsFirstExercise = $0 }),
                                    weight: Binding(get: { superSet.weightFirstExercise },
                                                    set: { superSet.weightFirstExercise = $0 }),
                                    repetitionsPlaceholder: repetitionsPlaceholder(for: superSet).first!,
                                    weightPlaceholder: weightsPlaceholder(for: superSet).first!)
            }
            HStack {
                Text("2")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                SetEntryEditor(repetitions: Binding(get: { superSet.repetitionsSecondExercise },
                                                         set: { superSet.repetitionsSecondExercise = $0 }),
                                    weight: Binding(get: { superSet.weightSecondExercise },
                                                    set: { superSet.weightSecondExercise = $0 }),
                                    repetitionsPlaceholder: repetitionsPlaceholder(for: superSet).second!,
                                    weightPlaceholder: weightsPlaceholder(for: superSet).second!)
            }.accentColor(superSet.secondaryExercise?.muscleGroup?.color)
        }
    }
    
}
