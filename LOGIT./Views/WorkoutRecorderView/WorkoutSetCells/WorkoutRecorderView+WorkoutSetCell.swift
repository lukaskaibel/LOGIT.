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
            HStack {
                ColorMeter(
                    items: [workoutSet.setGroup?.exercise?.muscleGroup?.color, workoutSet.setGroup?.secondaryExercise?.muscleGroup?.color]
                        .compactMap({$0}).map{ ColorMeter.Item(color: $0, amount: 1) },
                    splitStyle: .horizontal,
                    roundedEdges: workoutSetIsFirst(workoutSet: workoutSet) && workoutSetIsLast(workoutSet: workoutSet) ? .all :
                                  workoutSetIsFirst(workoutSet: workoutSet) ? .top :
                                  workoutSetIsLast(workoutSet: workoutSet) ? .bottom :
                                  .none
                )
                .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? CELL_PADDING : 0)
                .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? CELL_PADDING : 0)
                Spacer()
                Text("\(indexInSetGroup(for: workoutSet)! + 1)")
                    .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                Spacer()
            }
            .frame(maxWidth: 80)
            if let standardSet = workoutSet as? StandardSet {
                StandardSetCell(for: standardSet)
                    .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .frame(maxWidth: .infinity)
            } else if let dropSet = workoutSet as? DropSet {
                DropSetCell(for: dropSet)
                    .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .frame(maxWidth: .infinity)
            } else if let superSet = workoutSet as? SuperSet {
                SuperSetCell(for: superSet)
                    .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .frame(maxWidth: .infinity)
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
