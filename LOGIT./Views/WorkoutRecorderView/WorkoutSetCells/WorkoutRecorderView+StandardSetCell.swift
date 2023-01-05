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
            SetEntryEditor(
                repetitions: Binding(
                    get: { standardSet.repetitions },
                    set: { standardSet.repetitions = $0; workout.endDate = .now }
                ),
                weight: Binding(
                    get: { standardSet.weight },
                    set: { standardSet.weight = $0; workout.endDate = .now }
                ),
                repetitionsPlaceholder: repetitionsPlaceholder(for: standardSet),
                weightPlaceholder: weightPlaceholder(for: standardSet)
            )
        }
    }
    
}
