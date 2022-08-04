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
                Image(systemName: "swift")
                    .foregroundColor(.accentColor)
                    .padding(14)
                    .background(LinearGradient(colors: [.accentColor.opacity(0.03), .accentColor.opacity(0.3)],
                                               startPoint: .leading,
                                               endPoint: .trailing))
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(workout.date?.description(.short) ?? "")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondaryLabel)
                    Text(workout.name ?? "No name")
                        .font(.headline)
                        .lineLimit(1)
                    Text(exercisesString)
                        .lineLimit(1)
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
