//
//  SetGroupDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.10.22.
//

import SwiftUI

struct SetGroupDetailView: View {
    
    // MARK: - Graphical Constants
    
    static let columnWidth: CGFloat = 70
    static let columnSpace: CGFloat = 20
    
    // MARK: - Parameters
    
    let setGroup: WorkoutSetGroup
    let indexInWorkout: Int
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(for: setGroup)
            HStack {
                Capsule()
                    .foregroundColor(setGroup.exercise?.muscleGroup?.color ?? .separator)
                    .frame(width: 7)
                VStack(spacing: 0) {
                    Divider()
                        .padding(.leading)
                    ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                        VStack(alignment: .trailing, spacing: 0) {
                            EmptyView()
                                .frame(height: 1)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(NSLocalizedString("set", comment: "")) \((setGroup.index(of: workoutSet) ?? 0) + 1)")
                                        .font(.body.monospacedDigit())
                                    if workoutSet.isDropSet || workoutSet.isSuperSet {
                                        Text(workoutSet.isDropSet ? "Dropset" : "Superset")
                                            .font(.caption)
                                            .foregroundColor(.secondaryLabel)
                                    }
                                }
                                WorkoutSetCell(workoutSet: workoutSet)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                            }
                            Divider()
                        }.padding(.leading)
                    }
                }
            }
        }.tileStyle()
            
    }
    
    // MARK: - Supporting Views
    
    @ViewBuilder
    private func header(for setGroup: WorkoutSetGroup) -> some View {
        VStack(spacing: 3) {
            HStack {
                if let exercise = setGroup.exercise {
                    Text("\(indexInWorkout + 1).")
                    NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: exercise.objectID))) {
                        HStack(spacing: 3) {
                            Text("\(exercise.name ?? "")")
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.separator)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
            }.font(.body.weight(.semibold))
                .foregroundColor(.label)
            if setGroup.setType == .superSet, let secondaryExercise = setGroup.secondaryExercise {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption)
                    NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: secondaryExercise.objectID))) {
                        HStack(spacing: 3) {
                            Text("\(secondaryExercise.name ?? "")")
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.separator)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }.padding(.leading, 30)
            }
            HStack(spacing: SetGroupDetailView.columnSpace) {
                Spacer()
                Text(NSLocalizedString("reps", comment: "").uppercased())
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
                    .frame(maxWidth: SetGroupDetailView.columnWidth)
                Text(WeightUnit.used.rawValue.uppercased())
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
                    .frame(maxWidth: SetGroupDetailView.columnWidth)
            }.padding(.horizontal)
                .padding(.top, 5)
        }.font(.body.weight(.semibold))
            .foregroundColor(.label)
    }
    
}

struct SetGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SetGroupDetailView(setGroup: Database.getTestWorkout().setGroups.first!, indexInWorkout: 1)
    }
}
