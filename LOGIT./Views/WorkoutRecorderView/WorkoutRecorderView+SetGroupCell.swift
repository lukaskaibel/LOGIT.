//
//  SetGroupCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal func setGroupCell(for setGroup: WorkoutSetGroup) -> some View {
        Section {
            exerciseHeader(setGroup: setGroup)
                .deleteDisabled(true)
            ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                workoutSetCell(workoutSet: workoutSet)
            }.onDelete { indexSet in
                setGroup.sets.elements(for: indexSet).forEach { database.delete($0) }
                database.refreshObjects()
            }
            Button(action: {
                database.addSet(to: setGroup)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }) {
                Label(NSLocalizedString("addSet", comment: ""), systemImage: "plus.circle.fill")
                    .foregroundColor(setGroup.exercise?.muscleGroup?.color)
                    .font(.body.weight(.bold))
            }.padding(15)
                .frame(maxWidth: .infinity)
                .deleteDisabled(true)
        }.transition(.slide)
            .buttonStyle(.plain)
    }
    
    @ViewBuilder
    internal func exerciseHeader(setGroup: WorkoutSetGroup) -> some View {
        HStack {
            if let muscleGroup = setGroup.exercise?.muscleGroup {
                if setGroup.setType == .superSet, let secondaryMuscleGroup = setGroup.secondaryExercise?.muscleGroup {
                    VerticalMuscleGroupIndicator(muscleGroupAmounts: [(muscleGroup, 1), (secondaryMuscleGroup, 1)])
                } else {
                    VerticalMuscleGroupIndicator(muscleGroupAmounts: [(muscleGroup, 1)])
                }
            }
            VStack(spacing: 5) {
                HStack {
                    Button {
                        sheetType = .exerciseSelection(exercise: setGroup.exercise, setExercise: { exercise in
                            setGroup.exercise = exercise
                            database.refreshObjects()
                        })
                    } label: {
                        HStack(spacing: 3) {
                            if setGroup.setType == .superSet {
                                Image(systemName: "1.circle")
                            }
                            Text(setGroup.exercise?.name ?? "No Name")
                                .font(.title3.weight(.semibold))
                                .lineLimit(1)
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(setGroup.exercise?.muscleGroup?.color)
                    }
                    Spacer()
                    if !isEditing {
                        Menu(content: {
                            Section {
                                Button(action: {
                                    database.convertSetGroupToStandardSets(setGroup)
                                }) {
                                    Label(NSLocalizedString("normalset", comment: ""),
                                          systemImage: setGroup.setType == .standard ? "checkmark" : "")
                                }
                                Button(action: {
                                    database.convertSetGroupToSuperSets(setGroup)
                                }) {
                                    Label(NSLocalizedString("superset", comment: ""),
                                          systemImage: setGroup.setType == .superSet ? "checkmark" : "")
                                }
                                Button(action: {
                                    database.convertSetGroupToDropSets(setGroup)
                                }) {
                                    Label(NSLocalizedString("dropset", comment: ""),
                                          systemImage: setGroup.setType == .dropSet ? "checkmark" : "")
                                }
                            }
                            Section {
                                Button(action: {
                                    // TODO: Add Detail for Secondary Exercise in case of SuperSet
                                    guard let exercise = setGroup.exercise else { return }
                                    sheetType = .exerciseDetail(exercise: exercise)
                                }) {
                                    Label(NSLocalizedString("showDetails", comment: ""), systemImage: "info.circle")
                                }
                                Button(role: .destructive, action: {
                                    withAnimation {
                                        database.delete(setGroup)
                                    }
                                }) {
                                    Label(NSLocalizedString("remove", comment: ""), systemImage: "xmark.circle")
                                }
                            }
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.label)
                                .padding(7)
                        }
                    }
                }
                if setGroup.setType == .superSet {
                    HStack {
                        Image(systemName: "arrow.turn.down.right")
                            .padding(.leading)
                        Button {
                            sheetType = .exerciseSelection(exercise: setGroup.secondaryExercise,
                                                           setExercise: { setGroup.secondaryExercise = $0; database.refreshObjects() })
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: "2.circle")
                                Text(setGroup.secondaryExercise?.name ?? "Select second exercise")
                                    .font(.title3.weight(.semibold))
                                Image(systemName: "chevron.right")
                                    .fontWeight(.semibold)
                            }.foregroundColor(setGroup.secondaryExercise?.muscleGroup?.color ?? .secondaryLabel)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .padding(CELL_PADDING)
    }
    
}
