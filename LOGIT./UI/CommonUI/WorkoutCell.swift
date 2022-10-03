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
                    muscleGroupIndicator
                    VStack(alignment: .leading) {
                        Text(workout.date?.description(.short) ?? "")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.secondaryLabel)
                        Text(workout.name ?? "No name")
                            .font(.headline)
                            .lineLimit(1)
                        Text(exercisesString)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.separator)
            }
        }.padding(10)
            .background(Color.secondaryBackground)
            .cornerRadius(12)
    }

    private var muscleGroupIndicator: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(workout.muscleGroupOccurances, id:\.self.0.rawValue) { muscleGroupOccurance in
                    Rectangle()
                        .foregroundColor(muscleGroupOccurance.0.color)
                        .frame(maxHeight: geometry.size.height * CGFloat(muscleGroupOccurance.1)/CGFloat(workout.numberOfSets))
                }
            }
        }.frame(width: 7, height: 80)
            .clipShape(Capsule())
    }
    
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
