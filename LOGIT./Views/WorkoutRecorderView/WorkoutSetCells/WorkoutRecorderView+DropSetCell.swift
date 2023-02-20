//
//  WorkoutRecorderView+DropSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func dropSetCell(for dropSet: DropSet) -> some View {
        VStack {
            ForEach(0..<(dropSet.repetitions?.count ?? 0), id:\.self) { index in
                HStack {
                    IntegerField(
                        placeholder: repetitionsPlaceholder(for: dropSet).value(at: index) ?? 0,
                        value: dropSet.repetitions?.value(at: index) ?? 0,
                        setValue: { dropSet.repetitions?.replaceValue(at: index, with: $0); workout.endDate = .now },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: workout.sets.firstIndex(of: dropSet)!,
                            secondary: index,
                            tertiary: 0
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                    )
                    IntegerField(
                        placeholder: weightsPlaceholder(for: dropSet).value(at: index) ?? 0,
                        value: Int64(convertWeightForDisplaying(dropSet.weights?.value(at: index) ?? 0)),
                        setValue: { dropSet.weights?.replaceValue(at: index, with: $0); workout.endDate = .now },
                        maxDigits: 4,
                        index: IntegerField.Index(
                            primary: workout.sets.firstIndex(of: dropSet)!,
                            secondary: index,
                            tertiary: 1
                        ),
                        focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                    )
                }
            }
            Stepper(
                NSLocalizedString("dropCount", comment: ""),
                onIncrement: { dropSet.addDrop(); database.refreshObjects() },
                onDecrement: { dropSet.removeLastDrop(); database.refreshObjects() }
            )
            .accentColor(dropSet.exercise?.muscleGroup?.color)
        }
    }

}
