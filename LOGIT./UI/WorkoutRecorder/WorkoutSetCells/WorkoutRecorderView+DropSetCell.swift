//
//  WorkoutRecorderView+DropSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func DropSetCell(for dropSet: DropSet) -> some View {
        VStack {
            ForEach(0..<(dropSet.repetitions?.count ?? 0), id:\.self) { index in
                WorkoutSetEntryView(repetitions: Binding(get: { dropSet.repetitions?.value(at: index) ?? 0 },
                                                         set: { dropSet.repetitions?.replaceValue(at: index, with: $0) }),
                                    weight: Binding(get: { dropSet.weights?.value(at: index) ?? 0 },
                                                    set: { dropSet.weights?.replaceValue(at: index, with: $0) }),
                                    repetitionsPlaceholder: repetitionsPlaceholder(for: dropSet).value(at: index),
                                    weightPlaceholder: weightsPlaceholder(for: dropSet).value(at: index))
            }
            Stepper("Drop count",
                    onIncrement: { dropSet.addDrop(); database.refreshObjects() },
                    onDecrement: { dropSet.removeLastDrop(); database.refreshObjects() })
        }
    }

}
