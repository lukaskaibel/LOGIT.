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
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(workoutTemplate.name ?? "No Name")
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                Text(lastUsedDate)
                    .foregroundColor(.secondaryLabel)
                    .font(.subheadline)
            }
            Text(exercisesString)
                .foregroundColor(.secondaryLabel)
                .font(.subheadline)
                .lineLimit(1)
                .frame(maxWidth: 280, alignment: .leading)
            HStack {
                Text("\(workoutTemplate.numberOfSetGroups.description) exercise\(workoutTemplate.numberOfSetGroups == 1 ? "" : "s")")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                Spacer()
                Text("Template")
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 5)
                    .background(Color.fill)
                    .clipShape(Capsule())
                    .padding(.top, 3)
            }
        }
        .padding(.vertical, 4)
    }
    
    //MARK: - Computed UI Properties
    
    private var lastUsedDate: String {
        if let date = workoutTemplate.date {
            return "Last used \(date.description(.short))"
        } else {
            return "Unused"
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
        WorkoutTemplateCell(workoutTemplate: TemplateWorkout(context: Database.preview.container.viewContext))
    }
}
