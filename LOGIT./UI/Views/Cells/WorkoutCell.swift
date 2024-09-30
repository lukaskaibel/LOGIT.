//
//  WorkoutCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.07.22.
//

import Charts
import SwiftUI

struct WorkoutCell: View {

    // MARK: Variables

    @ObservedObject var workout: Workout

    // MARK: Body

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 12) {
                    if #available(iOS 17.0, *) {
                        Chart {
                            ForEach(workout.muscleGroupOccurances, id:\.0) { muscleGroupOccurance in
                                SectorMark(
                                    angle: .value("Value", muscleGroupOccurance.1),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 1
                                )
                                .foregroundStyle(muscleGroupOccurance.0.color.gradient)
                            }
                        }
                        .frame(width: 40, height: 40)
        //                .background(Color.yellow)
                    }
                    VStack(alignment: .leading) {
                        Text(
                            "\(workout.date?.description(.short) ?? "")  \(workout.date?.formatted(.dateTime.hour().minute()) ?? "")"
                        )
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondaryLabel)
                        Text(workout.name ?? NSLocalizedString("noName", comment: ""))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    NavigationChevron()
                        .foregroundStyle(.secondary)
                }
//                HStack {
//                    ForEach(workout.muscleGroups) { muscleGroup in
//                        Text(muscleGroup.description)
//                            .font(.system(.body, design: .rounded, weight: .bold))
//                            .foregroundStyle(muscleGroup.color.gradient)
//                            .lineLimit(1)
//                    }
//                }
//                Text("\(exercisesString)")
//                    .foregroundColor(.secondary)
//                    .lineLimit(2, reservesSpace: true)
            }
        }
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

private struct PreviewWrapperView: View {
    @EnvironmentObject private var database: Database
    
    var body: some View {
        ScrollView {
            WorkoutCell(workout: database.fetch(Workout.self).first! as! Workout)
                .padding(CELL_PADDING)
                .tileStyle()
        }
    }
}

struct WorkoutCell_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .padding()
            .previewEnvironmentObjects()
    }
}
