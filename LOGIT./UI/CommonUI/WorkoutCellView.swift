//
//  WorkoutCellView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 26.09.21.
//

import SwiftUI


struct WorkoutCellView: View {
    
    //MARK: Variables
    
    @ObservedObject var workout: Workout
    
    @State var isShowingAllExercises: Bool = false
    
    //MARK: Body
    
    var body: some View {
        NavigationLink(destination: WorkoutDetailView(workoutDetail: WorkoutDetail(context: Database.shared.container.viewContext,
                                                                                   workoutID: workout.objectID))) {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(workout.name ?? "No Name")
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    Spacer()
                    Text(date)
                        .foregroundColor(.secondaryLabel)
                }
                Text(exercisesString)
                    .foregroundColor(.secondaryLabel)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                    .frame(maxWidth: 280, alignment: .leading)
                Text("\(workout.numberOfSetGroups) exercise\(workout.numberOfSetGroups == 1 ? "" : "s")")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
            }
            .padding(.vertical, 4)
        }
    }
    
    //MARK: Computed Variabels
    
    private var date: String {
        if let date = workout.date {
            return date.description(.short)
        } else {
            return ""
        }
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

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCellView(workout: Workout(context: Database.preview.container.viewContext))
    }
}
