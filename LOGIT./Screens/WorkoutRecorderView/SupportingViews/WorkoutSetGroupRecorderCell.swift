//
//  WorkoutSetGroupRecorderCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.07.23.
//

import SwiftUI

extension WorkoutRecorderView {

    struct WorkoutSetGroupRecorderCell: View {
        
        // MARK: - Environment
        
        @EnvironmentObject var database: Database
        
        // MARK: - Parameters
        
        @ObservedObject var setGroup: WorkoutSetGroup
        
        @Binding var focusedIntegerFieldIndex: IntegerField.Index?
        @Binding var sheetType: WorkoutRecorderView.SheetType?
        @Binding var isEditing: Bool
        @Binding var editMode: EditMode
        
        // MARK: - Body
        
        var body: some View {
            VStack(spacing: SECTION_HEADER_SPACING) {
                header
                    .padding([.top, .horizontal], CELL_PADDING)
                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            Text(
                                setGroup.setType == .superSet ? NSLocalizedString("superset", comment: "").uppercased() :
                                setGroup.setType == .dropSet ? NSLocalizedString("dropset", comment: "").uppercased() :
                                NSLocalizedString("set", comment: "").uppercased()
                            )
                            .frame(maxWidth: 80)
                            Text(NSLocalizedString("reps", comment: "").uppercased())
                                .frame(maxWidth: .infinity)
                            Text(WeightUnit.used.rawValue.uppercased())
                                .frame(maxWidth: .infinity)
                        }
                        .font(.caption)
                        .foregroundColor(.secondaryLabel)
                        .padding(.horizontal, CELL_PADDING)
                        VStack(spacing: 0) {
                            ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                                WorkoutRecorderView.WorkoutSetCell(
                                    workoutSet: workoutSet,
                                    indexInWorkout: setGroup.workout!.sets.firstIndex(of: workoutSet)!,
                                    indexInSetGroup: setGroup.sets.firstIndex(of: workoutSet)!,
                                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                                )
                                .padding(.horizontal, CELL_PADDING)
                            }
                        }
                    }
                    
        //            .onDelete { indexSet in
        //                setGroup.sets.elements(for: indexSet).forEach { database.delete($0) }
        //                database.refreshObjects()
        //            }
                    Button {
                        database.addSet(to: setGroup)
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    } label: {
                        Label(NSLocalizedString("addSet", comment: ""),
                              systemImage: "plus.circle.fill")
                    }
                    .bigButton()
                    .padding([.bottom, .horizontal], CELL_PADDING)
                }
            }
            .accentColor(setGroup.exercise?.muscleGroup?.color ?? .accentColor)
        }
        
        // MARK: - Supporting Views
        
        private var header: some View {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(
                        "\(setGroup.workout!.setGroups.firstIndex(of: setGroup)! + 1) / \(setGroup.workout!.setGroups.count)   ·  \(setGroup.setType.description)"
                    )
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    .textCase(.none)
                    ExerciseHeader(
                        exercise: setGroup.exercise,
                        secondaryExercise: setGroup.secondaryExercise,
                        exerciseAction: {
                            sheetType = .exerciseSelection(
                                exercise: setGroup.exercise,
                                setExercise: { setGroup.exercise = $0; database.refreshObjects()}
                            )
                        },
                        secondaryExerciseAction: {
                            sheetType = .exerciseSelection(
                                exercise: setGroup.secondaryExercise,
                                setExercise: { setGroup.secondaryExercise = $0; database.refreshObjects() }
                            )
                        },
                        isSuperSet: setGroup.setType == .superSet,
                        navigationToDetailEnabled: true
                    )
                    HStack {
                        Text(setGroup.exercise?.muscleGroup?.description ?? "")
                            .foregroundColor(setGroup.exercise?.muscleGroup?.color ?? .accentColor)
                        if setGroup.setType == .superSet {
                            Text(setGroup.secondaryExercise?.muscleGroup?.description ?? "")
                                .foregroundColor(setGroup.secondaryExercise?.muscleGroup?.color ?? .accentColor)
                        }
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                }
                Spacer()
                Menu {
                    Section {
                        Button(role: .destructive, action: {
                            withAnimation {
                                database.delete(setGroup)
                            }
                        }) {
                            Label(NSLocalizedString("remove", comment: ""), systemImage: "xmark.circle")
                        }
                        Button {
                            isEditing = true
                            editMode = .active
                        } label: {
                            Label(NSLocalizedString("reorderExercises", comment: ""), systemImage: "arrow.up.arrow.down")
                        }
                    }
                    Section {
                        Button { database.convertSetGroupToStandardSets(setGroup) } label: {
                            Label(NSLocalizedString("standard", comment: ""),
                                  systemImage: setGroup.setType == .standard ? "checkmark" : "")
                        }
                        Button { database.convertSetGroupToSuperSets(setGroup) } label: {
                            Label(NSLocalizedString("superset", comment: ""),
                                  systemImage: setGroup.setType == .superSet ? "checkmark" : "")
                        }
                        Button { database.convertSetGroupToDropSets(setGroup) } label: {
                            Label(NSLocalizedString("dropset", comment: ""),
                                  systemImage: setGroup.setType == .dropSet ? "checkmark" : "")
                        }
                    } header: {
                        Text(NSLocalizedString("setType", comment: ""))
                    }
                    Section {
                        if let exercise = setGroup.exercise {
                            Button {
                                sheetType = .exerciseDetail(exercise: exercise)
                            } label: {
                                Label(exercise.name ?? NSLocalizedString("showDetail", comment: ""), systemImage: "info.circle")
                            }
                        }
                        if setGroup.setType == .superSet, let secondaryExercise = setGroup.secondaryExercise {
                            Button {
                                sheetType = .exerciseDetail(exercise: secondaryExercise)
                            } label: {
                                Label(secondaryExercise.name ?? NSLocalizedString("showDetail", comment: ""), systemImage: "info.circle")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            .font(.title3.weight(.bold))
            .foregroundColor(.label)
        }
    }

}


struct WorkoutSetGroupRecorderCell_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            WorkoutRecorderView.WorkoutSetGroupRecorderCell(
                setGroup: Database.preview.getWorkouts().first!.setGroups.first!,
                focusedIntegerFieldIndex: .constant(nil),
                sheetType: .constant(nil),
                isEditing: .constant(false),
                editMode: .constant(.inactive)
            )
            .tileStyle()
            .padding()
        }
        .environmentObject(Database.preview)
    }
}
