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
                SetEntryEditor(
                    repetitions: Binding(
                        get: { dropSet.repetitions?.value(at: index) ?? 0 },
                        set: { dropSet.repetitions?.replaceValue(at: index, with: $0); workout.endDate = .now }
                    ),
                    weight: Binding(
                        get: { dropSet.weights?.value(at: index) ?? 0 },
                        set: { dropSet.weights?.replaceValue(at: index, with: $0); workout.endDate = .now }
                    ),
                    repetitionsPlaceholder: repetitionsPlaceholder(for: dropSet).value(at: index),
                    weightPlaceholder: weightsPlaceholder(for: dropSet).value(at: index)
                )
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
