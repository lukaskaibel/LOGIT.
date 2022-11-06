//
//  WorkoutDoneView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.10.22.
//

import SwiftUI
import CoreData

struct WorkoutDoneView: View {
    
    // MARK: - Parameters
    
    let workout: Workout
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack {
                title
                workoutHeader
                setGroupList
            }
        }
    }
    
    // MARK: - Supporting Views
    
    var title: some View {
        VStack(alignment: .leading) {
            Text("Workout Completed")
                .fontWeight(.medium)
            Text("Great Work!")
                .font(.largeTitle.weight(.bold))
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
    
    var workoutHeader: some View {
        HStack {
            Image(systemName: "swift")
                .font(.title)
                .foregroundColor(.accentColor)
                .padding()
                .background(LinearGradient(colors: [.accentColor.opacity(0.03), .accentColor.opacity(0.3)],
                                           startPoint: .leading,
                                           endPoint: .trailing))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(workout.name ?? "No Name")
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                Text("\(workout.numberOfSetGroups) \(NSLocalizedString("exercise\(workout.numberOfSetGroups == 1 ? "" : "s")", comment: "")) , \(workout.numberOfSets) \(NSLocalizedString("set\(workout.numberOfSets == 1 ? "" : "s")", comment: ""))")
                    .foregroundColor(.accentColor)
            }
            Spacer()
        }.padding()
    }
    
    var setGroupList: some View {
        ForEach(workout.setGroups) { setGroup in
            SetGroupDetailView(setGroup: setGroup,
                               indexInWorkout: workout.index(of: setGroup) ?? 1)
        }
    }
    
   
    
}

struct WorkoutDoneView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDoneView(workout: Database.preview.testWorkout)
    }
}
