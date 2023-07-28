//
//  WorkoutRecorderView+WorkoutSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    struct WorkoutSetCell: View {
        
        // MARK: - Environment
        
        @EnvironmentObject var database: Database
        
        // MARK: - Parameters
        
        @ObservedObject var workoutSet: WorkoutSet
        let indexInWorkout: Int
        let indexInSetGroup: Int
        @Binding var focusedIntegerFieldIndex: IntegerField.Index?
      
        // MARK: - Body

        var body: some View {
            VStack(spacing: CELL_PADDING) {
                HStack {
                    Text("\(NSLocalizedString("set", comment: "")) \(indexInSetGroup + 1)")
                    Spacer()
                    if let standardSet = workoutSet as? StandardSet {
                        StandardSetCell(
                            standardSet: standardSet,
                            indexInWorkout: indexInWorkout,
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                        .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2)
                        .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2)
                    } else if let dropSet = workoutSet as? DropSet {
                        DropSetCell(
                            dropSet: dropSet,
                            indexInWorkout: indexInWorkout,
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                        .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2)
                        .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2)
                    } else if let superSet = workoutSet as? SuperSet {
                        SuperSetCell(
                            superSet: superSet,
                            indexInWorkout: indexInWorkout,
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                        .padding(.top, workoutSetIsFirst(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2)
                        .padding(.bottom, workoutSetIsLast(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2)
                    }
                }
                if let dropSet = workoutSet as? DropSet {
                    Divider()
                    Stepper(
                        NSLocalizedString("dropCount", comment: ""),
                        onIncrement: { dropSet.addDrop(); database.refreshObjects() },
                        onDecrement: { dropSet.removeLastDrop(); database.refreshObjects() }
                    )
                    .accentColor(dropSet.exercise?.muscleGroup?.color)
                }
            }
        }
        
        // MARK: - Supporting Methods
        
        private func workoutSetIsFirst(workoutSet: WorkoutSet) -> Bool {
            guard let setGroup = workoutSet.setGroup else { return false }
            return setGroup.sets.firstIndex(of: workoutSet) == 0
        }
        
        private func workoutSetIsLast(workoutSet: WorkoutSet) -> Bool {
            guard let setGroup = workoutSet.setGroup else { return false }
            return setGroup.sets.firstIndex(of: workoutSet) == setGroup.numberOfSets - 1
        }
        
    }
    
}
