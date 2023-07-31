//
//  WorkoutCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.07.22.
//

import SwiftUI

struct WorkoutCell: View {

    // MARK: Variables

    @ObservedObject var workout: Workout

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(
                        "\(workout.date?.description(.short) ?? "")  ·  \(workout.numberOfSetGroups) \(NSLocalizedString("exercise" + "\(workout.numberOfSetGroups == 1 ? "" : "s")", comment: ""))"
                    )
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    Text(workout.name ?? NSLocalizedString("noName", comment: ""))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                Spacer()
                NavigationChevron()
                    .muscleGroupGradientStyle(for: workout.muscleGroups)
            }
            HStack {
                ForEach(workout.muscleGroups) { muscleGroup in
                    Text(muscleGroup.description)
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundStyle(muscleGroup.color.gradient)
                        .lineLimit(1)
                }
            }
            Text("\(exercisesString)")
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Computed UI Properties

    private var exercisesString: String {
        var result = ""
        for exercise in workout.exercises {
            if let name = exercise.name {
                result += (!result.isEmpty ? ", " : "") + name
            }
        }
        return result.isEmpty ? " " : result
    }

}

struct WorkoutCell_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            WorkoutCell(workout: Database.preview.fetch(Workout.self).first! as! Workout)
                .padding(CELL_PADDING)
                .tileStyle()
        }
        .environmentObject(Database.preview)
    }
}
