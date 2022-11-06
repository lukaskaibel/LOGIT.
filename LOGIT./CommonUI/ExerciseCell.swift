//
//  ExerciseCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.10.22.
//

import SwiftUI

struct ExerciseCell: View {
    
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VerticalMuscleGroupIndicator(muscleGroupAmounts: [(exercise.muscleGroup ?? .chest, 1)])
            VStack(alignment: .leading) {
                Text(NSLocalizedString("lastUsed", comment: "") + ": " + (exercise.sets.last?.workout?.date?.description(.short) ?? NSLocalizedString("never", comment: "")))
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    .lineLimit(1)
                Text(exercise.name ?? "")
                    .font(.headline)
            }
            Spacer()
        }.padding(CELL_PADDING)
    }
}

struct ExerciseCell_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseCell(exercise: Database.preview.newExercise(name: "Push-Up",
                                                           muscleGroup: .chest))
    }
}
