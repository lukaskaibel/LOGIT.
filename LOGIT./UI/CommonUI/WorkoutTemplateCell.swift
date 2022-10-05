//
//  WorkoutTemplateCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct WorkoutTemplateCell: View {
    
    // MARK: - Variables
    
    @ObservedObject var workoutTemplate: TemplateWorkout
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                VerticalMuscleGroupIndicator(muscleGroupAmounts: workoutTemplate.muscleGroupOccurances)
                VStack(alignment: .leading) {
                    Text(lastUsedDate)
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondaryLabel)
                    Text(workoutTemplate.name ?? "No name")
                        .font(.headline)
                        .lineLimit(1)
                    Text(exercisesString)
                        .lineLimit(2, reservesSpace: true)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.body.weight(.medium))
                .foregroundColor(.secondaryLabel)
        }.cellTileStyle()
    }
    
    //MARK: - Computed UI Properties
    
    private var lastUsedDate: String {
        if let date = workoutTemplate.date {
            return "\(NSLocalizedString("lastUsed", comment: "")) \(date.description(.short))"
        } else {
            return NSLocalizedString("unused", comment: "")
        }
    }
    
    private var exercisesString: String {
        var result = ""
        for exercise in workoutTemplate.exercises {
            if let name = exercise.name {
                result += (!result.isEmpty ? ", " : "") + name
            }
        }
        return result.isEmpty ? " " : result
    }
    
}

struct WorkoutTemplateCell_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTemplateCell(workoutTemplate: Database.preview.newTemplateWorkout(name: "Pushday"))
    }
}
