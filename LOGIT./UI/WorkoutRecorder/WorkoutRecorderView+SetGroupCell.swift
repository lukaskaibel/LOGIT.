//
//  SetGroupCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func setGroupCell(for setGroup: WorkoutSetGroup) -> some View {
        Section {
            exerciseHeader(setGroup: setGroup)
                .deleteDisabled(true)
            ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                workoutSetCell(workoutSet: workoutSet)
            }.onDelete { indexSet in
                setGroup.sets.elements(for: indexSet).forEach { database.delete($0) }
                database.refreshObjects()
            }
            Button(action: {
                database.addSet(to: setGroup)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }) {
                Label(NSLocalizedString("addSet", comment: ""), systemImage: "plus.circle.fill")
                    .foregroundColor(setGroup.exercise?.muscleGroup?.color)
                    .font(.body.weight(.bold))
            }.padding(15)
                .frame(maxWidth: .infinity)
                .deleteDisabled(true)
        }.transition(.slide)
            .buttonStyle(.plain)
    }
    
}
