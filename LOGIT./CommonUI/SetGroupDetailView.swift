//
//  SetGroupDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.10.22.
//

import SwiftUI

struct SetGroupDetailView: View {
    
    enum NavigationDestination {
        case exerciseDetail, secondaryExerciseDetail
    }
    
    // MARK: - Graphical Constants
    
    static let columnWidth: CGFloat = 70
    static let columnSpace: CGFloat = 20
    
    // MARK: - State
    
    @State private var navigateToDetail = false
    @State private var exerciseForDetail: Exercise? = nil
    
    // MARK: - Parameters
    
    let setGroup: WorkoutSetGroup
    let indexInWorkout: Int
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(for: setGroup)
            HStack {
                ColorMeter(items: [setGroup.exercise?.muscleGroup?.color,
                                   setGroup.secondaryExercise?.muscleGroup?.color]
                    .compactMap({$0}).map{ ColorMeter.Item(color: $0, amount: 1) })
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
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let exercise = exerciseForDetail {
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
    
    // MARK: - Supporting Views
    
    @ViewBuilder
    private func header(for setGroup: WorkoutSetGroup) -> some View {
        VStack(spacing: 3) {
            HStack {
                if let exercise = setGroup.exercise {
                    Text("\(indexInWorkout + 1).")
                    Button {
                        exerciseForDetail = exercise
                        navigateToDetail = true
                    } label: {
                        Text("\(exercise.name ?? "")")
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                    }.buttonStyle(.plain)
                    Spacer()
                }
            }.font(.title3.weight(.semibold))
                .foregroundColor(setGroup.exercise?.muscleGroup?.color)
            if setGroup.setType == .superSet, let secondaryExercise = setGroup.secondaryExercise {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption)
                    Button {
                        exerciseForDetail = secondaryExercise
                        navigateToDetail = true
                    } label: {
                        HStack(spacing: 3) {
                            Text("\(secondaryExercise.name ?? "")")
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.semibold))
                        }.font(.title3.weight(.semibold))
                            .foregroundColor(secondaryExercise.muscleGroup?.color)
                    }.buttonStyle(.plain)
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
                .padding(.vertical, 5)
        }.font(.body.weight(.semibold))
            .foregroundColor(.label)
    }
    
}

struct SetGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SetGroupDetailView(setGroup: Database.preview.testWorkout.setGroups.first!, indexInWorkout: 1)
            .environmentObject(Database.preview)
    }
}
