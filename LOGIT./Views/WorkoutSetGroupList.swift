//
//  WorkoutSetGroupList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 29.07.23.
//

import SwiftUI

struct WorkoutSetGroupList: View {

    @ObservedObject var workout: Workout
    @Binding var focusedIntegerFieldIndex: IntegerField.Index?
    @Binding var sheetType: WorkoutRecorderScreen.SheetType?
    @Binding var isReordering: Bool

    var body: some View {
        VStack(spacing: SECTION_SPACING) {
            ForEach(workout.setGroups, id: \.objectID) { setGroup in
                WorkoutSetGroupCell(
                    setGroup: setGroup,
                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                    sheetType: $sheetType,
                    isReordering: $isReordering,
                    supplementaryText:
                        "\(workout.setGroups.firstIndex(of: setGroup)! + 1) / \(workout.setGroups.count)  ·  \(setGroup.setType.description)"
                )
                .padding(CELL_PADDING)
                .tileStyle()
            }
        }
    }
}

struct WorkoutSetGroupList_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSetGroupList(
            workout: Database.preview.getWorkouts().first!,
            focusedIntegerFieldIndex: .constant(nil),
            sheetType: .constant(nil),
            isReordering: .constant(false)
        )
    }
}
