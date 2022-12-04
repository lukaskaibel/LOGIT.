//
//  ExerciseCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.10.22.
//

import SwiftUI

struct ExerciseCell: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database
    
    // MARK: - Parameters
    
    let exercise: Exercise
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            ColorMeter(items: exercise.muscleGroup?.color != nil ? [ColorMeter.Item(color: exercise.muscleGroup!.color, amount: 1)] : [])
            VStack(alignment: .leading) {
                Text(NSLocalizedString("lastUsed", comment: "") + ": " + (lastUsed?.description(.short) ?? NSLocalizedString("never", comment: "")))
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    .lineLimit(1)
                Text(exercise.name ?? "")
                    .font(.headline)
            }
            Spacer()
        }.padding(CELL_PADDING)
    }
    
    // MARK: - Computed Properties
    
    private var lastUsed: Date? {
        database.getWorkoutSetGroups(with: exercise).last?.workout?.date
    }
    
}

struct ExerciseCell_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseCell(exercise: Database.preview.newExercise(name: "Push-Up",
                                                           muscleGroup: .chest))
    }
}
