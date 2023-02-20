//
//  WorkoutRecorderView+StandardSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func standardSetCell(for standardSet: StandardSet) -> some View {
        return HStack {
            IntegerField(
                placeholder: repetitionsPlaceholder(for: standardSet),
                value: standardSet.repetitions,
                setValue: { standardSet.repetitions = $0; workout.endDate = .now },
                maxDigits: 4,
                index: IntegerField.Index(
                    primary: workout.sets.firstIndex(of: standardSet)!,
                    secondary: 0,
                    tertiary: 0
                ),
                focusedIntegerFieldIndex: $focusedIntegerFieldIndex
            )
            IntegerField(
                placeholder: weightPlaceholder(for: standardSet),
                value: Int64(convertWeightForDisplaying(standardSet.weight)),
                setValue: { standardSet.weight = convertWeightForStoring($0); workout.endDate = .now },
                maxDigits: 4,
                index: IntegerField.Index(
                    primary: workout.sets.firstIndex(of: standardSet)!,
                    secondary: 0,
                    tertiary: 1
                ),
                focusedIntegerFieldIndex: $focusedIntegerFieldIndex
            )
        }
    }
    
}
