//
//  WorkoutRecorderView+StandardSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func StandardSetCell(for standardSet: StandardSet) -> some View {
        return HStack {
            WorkoutSetEntryView(repetitions: Binding(get: {standardSet.repetitions},
                                                     set: {standardSet.repetitions = $0}),
                                weight: Binding(get: {standardSet.weight},
                                                set: {standardSet.weight = $0}),
                                repetitionsPlaceholder: repetitionsPlaceholder(for: standardSet),
                                weightPlaceholder: weightPlaceholder(for: standardSet))
        }
    }
    
}
