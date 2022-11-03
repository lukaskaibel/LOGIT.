//
//  WorkoutRecorderView+ExerciseHeader.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    @ViewBuilder
    internal func ExerciseHeader(setGroup: WorkoutSetGroup) -> some View {
        VStack(spacing: 0) {
            EmptyView()
                .frame(height: 1)
            VStack(spacing: 5) {
                HStack {
                    Button(action: {
                        sheetType = .exerciseSelection(exercise: setGroup.exercise, setExercise: { exercise in
                            setGroup.exercise = exercise
                            database.refreshObjects()
                        })
                        isShowingSheet = true
                    }) {
                        HStack(spacing: 3) {
                            if setGroup.setType == .superSet {
                                Image(systemName: "1.circle")
                            }
                            Text(setGroup.exercise?.name ?? "No Name")
                                .font(.title3.weight(.medium))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }.foregroundColor(setGroup.exercise == nil ? .secondaryAccentColor : .accentColor)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.accentColorBackground)
                            .cornerRadius(5)
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
                                    isShowingSheet = true
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
                        Button(action: {
                            sheetType = .exerciseSelection(exercise: setGroup.secondaryExercise, setExercise: { exercise in
                                setGroup.secondaryExercise = exercise
                            })
                            isShowingSheet = true
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "2.circle")
                                Text(setGroup.secondaryExercise?.name ?? "Select second exercise")
                                    .font(.title3.weight(.medium))
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }.foregroundColor(setGroup.secondaryExercise == nil ? .secondaryAccentColor : .accentColor)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(Color.accentColorBackground)
                                .cornerRadius(5)
                        }
                        Spacer()
                    }
                }
            }.padding(.horizontal)
                .padding(.vertical, 10)
            if !isEditing {
                Divider()
                    .padding(.leading)
                    .padding(.bottom, 5)
            }
        }
    }

    
}
