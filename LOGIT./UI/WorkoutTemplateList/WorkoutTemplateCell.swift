//
//  WorkoutTemplateCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct WorkoutTemplateCell: View {
    
    @ObservedObject var workoutTemplate: TemplateWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(lastUsedDate)
                    .foregroundColor(.secondaryLabel)
                    .font(.caption.weight(.semibold))
                Spacer()
                Text(NSLocalizedString("template", comment: ""))
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 5)
                    .background(Color.fill)
                    .clipShape(Capsule())
            }
            Text(workoutTemplate.name ?? "No Name")
                .font(.body.weight(.semibold))
                .lineLimit(1)
            Text(exercisesString)
                .lineLimit(1)
                .frame(maxWidth: 280, alignment: .leading)
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
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
