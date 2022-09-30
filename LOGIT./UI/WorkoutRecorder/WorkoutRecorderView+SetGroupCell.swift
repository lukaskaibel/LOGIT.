//
//  SetGroupCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func SetGroupCell(for setGroup: WorkoutSetGroup) -> some View {
        Section {
            ExerciseHeader(setGroup: setGroup)
                .deleteDisabled(true)
            ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                WorkoutSetCell(workoutSet: workoutSet)
            }.onDelete { indexSet in
                workoutRecorder.delete(setsWithIndices: indexSet, in: setGroup)
            }
            Button(action: {
                workoutRecorder.addSet(to: setGroup)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }) {
                Label(NSLocalizedString("addSet", comment: ""), systemImage: "plus.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.bold))
            }.padding(15)
                .frame(maxWidth: .infinity)
                .deleteDisabled(true)
        }.transition(.slide)
            .buttonStyle(.plain)
    }
    
}
