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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(alignment: .top) {
                    ColorMeter(items: workout.muscleGroupOccurances.map {
                        ColorMeter.Item(color: $0.color, amount: $1)
                    })
                    VStack(alignment: .leading) {
                        Text("\(workout.date?.description(.short) ?? "")  ·  \(workout.numberOfSetGroups) \(NSLocalizedString("exercise" + "\(workout.numberOfSetGroups == 1 ? "" : "s")", comment: ""))")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.secondaryLabel)
                        Text(workout.name ?? NSLocalizedString("noName", comment: ""))
                            .font(.headline)
                            .lineLimit(1)
                        Text(exercisesString)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
                Spacer()
                NavigationChevron()
                    .foregroundColor(workout.primaryMuscleGroup?.color ?? .separator)
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

struct WorkoutCell_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCell(workout: Database.preview.fetch(Workout.self).first! as! Workout)
    }
}
