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
        VStack(alignment: .leading) {
            Text(NSLocalizedString("lastUsed", comment: "") + ": " + (lastUsed?.description(.short) ?? NSLocalizedString("never", comment: "")))
                .font(.footnote.weight(.medium))
                .foregroundColor(.secondaryLabel)
                .lineLimit(1)
            Text(exercise.name ?? "")
                .font(.body.weight(.bold))
                .foregroundColor(.primary)
            Text(exercise.muscleGroup?.description ?? "")
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundStyle(exercise.muscleGroup?.color.gradient ?? Color.primary.gradient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Computed Properties
    
    private var lastUsed: Date? {
        database.getWorkoutSetGroups(with: exercise).last?.workout?.date
    }
    
}

struct ExerciseCell_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ExerciseCell(exercise: Database.preview.getExercises().first!)
                .padding(CELL_PADDING)
                .tileStyle()
        }
        .environmentObject(Database.preview)
    }
}
