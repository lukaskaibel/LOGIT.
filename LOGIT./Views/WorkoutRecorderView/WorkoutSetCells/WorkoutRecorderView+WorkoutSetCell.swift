//
//  WorkoutRecorderView+WorkoutSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    @ViewBuilder
    internal func workoutSetCell(workoutSet: WorkoutSet) -> some View {
        HStack {
            ZStack {
                ColorMeter(items: [ColorMeter.Item(color: workoutSet.setGroup?.exercise?.muscleGroup?.color.translucentBackground ?? .placeholder,
                                                   amount: 1)],
                           roundedEdges: workoutSetIsFirst(workoutSet: workoutSet) && workoutSetIsLast(workoutSet: workoutSet) ? .all :
                                            workoutSetIsFirst(workoutSet: workoutSet) ? .top :
                                            workoutSetIsLast(workoutSet: workoutSet) ? .bottom :
                                            .none)
                Text(String((indexInSetGroup(for: workoutSet) ?? 0) + 1))
                    .font(.system(.body, design: .rounded, weight: .medium).monospacedDigit())
                    .foregroundColor(.white)
                    .padding(6)
                    .background(workoutSet.setGroup?.exercise?.muscleGroup?.color ?? .placeholder)
                    .clipShape(Circle())
            }
            
            
            if let standardSet = workoutSet as? StandardSet {
                StandardSetCell(for: standardSet)
            } else if let dropSet = workoutSet as? DropSet {
                DropSetCell(for: dropSet)
                    .padding(.vertical, 8)
            } else if let superSet = workoutSet as? SuperSet {
                SuperSetCell(for: superSet)
                    .padding(.vertical, 8)
            }
            if let templateSet = workoutSetTemplateSetDictionary[workoutSet],
               templateSet.hasEntry {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    if workoutSet.hasEntry {
                        workoutSet.clearEntries()
                        database.refreshObjects()
                    } else {
                        workoutSet.match(templateSet)
                        database.refreshObjects()
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundColor(workoutSet.hasEntry ? .accentColor : .secondaryLabel)
                        .padding(10)
                        .frame(maxHeight: .infinity)
                        .background(workoutSet.hasEntry ? Color.accentColor.secondaryTranslucentBackground : .tertiaryFill)
                        .cornerRadius(5)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, CELL_PADDING)
    }

    private func workoutSetIsFirst(workoutSet: WorkoutSet) -> Bool {
        workoutSet.setGroup!.sets.firstIndex(of: workoutSet)! == 0
    }
    
    private func workoutSetIsLast(workoutSet: WorkoutSet) -> Bool {
        workoutSet.setGroup!.sets.firstIndex(of: workoutSet)! == workoutSet.setGroup!.numberOfSets - 1
    }
    
}
