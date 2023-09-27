//
//  WorkoutSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

struct WorkoutSetCell: View {

    // MARK: - Environment

    @Environment(\.canEdit) var canEdit: Bool
    @EnvironmentObject var database: Database

    // MARK: - Parameters

    @ObservedObject var workoutSet: WorkoutSet
    @Binding var focusedIntegerFieldIndex: IntegerField.Index?

    // MARK: - Body

    var body: some View {
        VStack(spacing: CELL_PADDING) {
            if let indexInSetGroup = indexInSetGroup {
                HStack {
                    Text("\(NSLocalizedString("set", comment: "")) \(indexInSetGroup + 1)")
                    Spacer()
                    if let standardSet = workoutSet as? StandardSet {
                        StandardSetCell(
                            standardSet: standardSet,
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                        .padding(
                            .top,
                            workoutSetIsFirst(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2
                        )
                        .padding(
                            .bottom,
                            workoutSetIsLast(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2
                        )
                    } else if let dropSet = workoutSet as? DropSet {
                        DropSetCell(
                            dropSet: dropSet,
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                        .padding(
                            .top,
                            workoutSetIsFirst(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2
                        )
                        .padding(
                            .bottom,
                            workoutSetIsLast(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2
                        )
                    } else if let superSet = workoutSet as? SuperSet {
                        SuperSetCell(
                            superSet: superSet,
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                        .padding(
                            .top,
                            workoutSetIsFirst(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2
                        )
                        .padding(
                            .bottom,
                            workoutSetIsLast(workoutSet: workoutSet) ? 0 : CELL_SPACING / 2
                        )
                    }
                }
                if let dropSet = workoutSet as? DropSet, canEdit {
                    Divider()
                    Stepper(
                        NSLocalizedString("dropCount", comment: ""),
                        onIncrement: {
                            dropSet.addDrop()
                            database.refreshObjects()
                        },
                        onDecrement: {
                            dropSet.removeLastDrop()
                            database.refreshObjects()
                        }
                    )
                    .accentColor(dropSet.exercise?.muscleGroup?.color)
                }
            }
        }
    }

    // MARK: - Supporting Methods

    private var indexInSetGroup: Int? {
        workoutSet.setGroup?.sets.firstIndex(of: workoutSet)
    }

    private func workoutSetIsFirst(workoutSet: WorkoutSet) -> Bool {
        guard let setGroup = workoutSet.setGroup else { return false }
        return setGroup.sets.firstIndex(of: workoutSet) == 0
    }

    private func workoutSetIsLast(workoutSet: WorkoutSet) -> Bool {
        guard let setGroup = workoutSet.setGroup else { return false }
        return setGroup.sets.firstIndex(of: workoutSet) == setGroup.numberOfSets - 1
    }

}