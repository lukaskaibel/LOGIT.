//
//  WorkoutRecorderView+WorkoutSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    @ViewBuilder
    internal func WorkoutSetCell(workoutSet: WorkoutSet) -> some View {
        HStack {
            Text(String((workoutRecorder.indexInSetGroup(for: workoutSet) ?? 0) + 1))
                .foregroundColor(.secondaryLabel)
                .font(.body.monospacedDigit())
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
            if let standardSet = workoutSet as? StandardSet {
                StandardSetCell(for: standardSet)
            } else if let dropSet = workoutSet as? DropSet {
                DropSetCell(for: dropSet)
                    .padding(.vertical, 8)
            } else if let superSet = workoutSet as? SuperSet {
                SuperSetCell(for: superSet)
                    .padding(.vertical, 8)
            }
            if let templateSet = workoutRecorder.templateSet(for: workoutSet),
               templateSet.hasEntry {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    if workoutSet.hasEntry {
                        workoutSet.clearEntries()
                    } else {
                        workoutSet.match(templateSet)
                    }
                    workoutRecorder.updateView()
                }) {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundColor(workoutSet.hasEntry ? .accentColor : .secondaryLabel)
                        .padding(7)
                        .frame(maxHeight: .infinity)
                        .background(workoutSet.hasEntry ? Color.accentColorBackground : .tertiaryFill)
                        .cornerRadius(5)
                        .padding(.vertical, 8)
                }
            }
        }.padding(.trailing)
    }

    
}
