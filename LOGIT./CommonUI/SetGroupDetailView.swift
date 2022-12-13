//
//  SetGroupDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.10.22.
//

import SwiftUI

struct SetGroupDetailView: View {
            
    // MARK: - State
    
    @State private var navigateToDetail = false
    @State private var exerciseForDetail: Exercise? = nil
    
    // MARK: - Parameters
    
    let setGroup: WorkoutSetGroup
    let supplementaryText: String
    let navigationToDetailEnabled: Bool
    
    // MARK: - Init
    
    init(setGroup: WorkoutSetGroup, supplementaryText: String, navigationToDetailEnabled: Bool = true) {
        self.setGroup = setGroup
        self.supplementaryText = supplementaryText
        self.navigationToDetailEnabled = navigationToDetailEnabled
    }
    
    // MARK: - Body
    
    var body: some View {
        Section {
            HStack(spacing: 0) {
                Text(
                    setGroup.setType == .superSet ? NSLocalizedString("superset", comment: "").uppercased() :
                    setGroup.setType == .dropSet ? NSLocalizedString("dropset", comment: "").uppercased() :
                    NSLocalizedString("set", comment: "").uppercased()
                )
                .frame(maxWidth: SET_GROUP_FIRST_COLUMN_WIDTH)
                Text(NSLocalizedString("reps", comment: "").uppercased())
                    .frame(maxWidth: .infinity)
                Text(WeightUnit.used.rawValue.uppercased())
                    .frame(maxWidth: .infinity)
            }
            .font(.caption)
            .foregroundColor(.secondaryLabel)
            .padding(.horizontal, CELL_PADDING)
            .listRowBackground(Color.fill)
            .listRowInsets(EdgeInsets())
            ZStack {
                ColorMeter(
                    items: [setGroup.exercise?.muscleGroup?.color, setGroup.secondaryExercise?.muscleGroup?.color]
                                .compactMap({$0}).map{ ColorMeter.Item(color: $0, amount: 1) },
                    splitStyle: .horizontal
                )
                .padding( .vertical, CELL_PADDING)
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 0) {
                    ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                        HStack(spacing: 0) {
                            Text("\((setGroup.index(of: workoutSet) ?? 0) + 1)")
                                .font(.body.monospacedDigit())
                                .frame(maxWidth: SET_GROUP_FIRST_COLUMN_WIDTH)
                            VStack(spacing: 0) {
                                EmptyView()
                                    .frame(height: 1)
                                WorkoutSetCell(workoutSet: workoutSet)
                                    .padding(.vertical, 15)
                                Divider()
                                    .padding(.leading)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, CELL_PADDING)
            .listRowInsets(EdgeInsets())
        } header: {
            VStack(alignment: .leading, spacing: 0) {
                Text(supplementaryText)
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    .textCase(.none)
                ExerciseHeader(
                    exercise: setGroup.exercise,
                    secondaryExercise: setGroup.secondaryExercise,
                    exerciseAction: { exerciseForDetail = setGroup.exercise; navigateToDetail = true },
                    secondaryExerciseAction: { exerciseForDetail = setGroup.secondaryExercise },
                    isSuperSet: setGroup.setType == .superSet,
                    navigationToDetailEnabled: navigationToDetailEnabled
                )
            }
            .padding(.vertical, 10)
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let exercise = exerciseForDetail {
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
    
}

struct SetGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SetGroupDetailView(setGroup: Database.preview.testWorkout.setGroups.first!, supplementaryText: "")
            .environmentObject(Database.preview)
    }
}
