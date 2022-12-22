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
            HStack {
                Text(setGroup.setType == .superSet ? NSLocalizedString("superset", comment: "").uppercased() :
                        setGroup.setType == .dropSet ? NSLocalizedString("dropset", comment: "").uppercased() :
                        NSLocalizedString("set", comment: "").uppercased())
                    .frame(maxWidth: 80)
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
            ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                workoutSetCell(workoutSet: workoutSet)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        if let templateSet = workoutSetTemplateSetDictionary[workoutSet] {
                            Button {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                if workoutSet.hasEntry {
                                    workoutSet.clearEntries()
                                    database.refreshObjects()
                                } else {
                                    workoutSet.match(templateSet)
                                    database.refreshObjects()
                                }
                            } label: {
                                Image(systemName: "checkmark")
                            }
                            .tint(.green)
                        }
                    }
            }
            .onDelete { indexSet in
                setGroup.sets.elements(for: indexSet).forEach { database.delete($0) }
                database.refreshObjects()
            }
            Button {
                database.addSet(to: setGroup)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            } label: {
                Label(NSLocalizedString("addSet", comment: ""),
                      systemImage: "plus.circle.fill")
                    .foregroundColor(setGroup.exercise?.muscleGroup?.color)
                    .font(.system(.body, design: .rounded, weight: .bold))
            }
            .padding(15)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.fill)
        } header: {
            exerciseHeader(setGroup: setGroup)
        }
        .listRowInsets(EdgeInsets())
        .buttonStyle(.plain)
        .accentColor(setGroup.exercise?.muscleGroup?.color ?? .accentColor)
    }
    
    @ViewBuilder
    internal func exerciseHeader(setGroup: WorkoutSetGroup) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(workout.setGroups.firstIndex(of: setGroup)! + 1) / \(workout.setGroups.count)  ·  \(setGroup.sets.count) \(NSLocalizedString("set" + (setGroup.sets.count == 1 ? "" : "s"), comment: ""))")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondaryLabel)
                    .textCase(.none)
                ExerciseHeader(
                    exercise: setGroup.exercise,
                    secondaryExercise: setGroup.secondaryExercise,
                    exerciseAction: {
                        sheetType = .exerciseSelection(exercise: setGroup.exercise,
                                                       setExercise: { setGroup.exercise = $0; database.refreshObjects()}) },
                    secondaryExerciseAction: {
                        sheetType = .exerciseSelection(exercise: setGroup.secondaryExercise,
                                                       setExercise: { setGroup.secondaryExercise = $0; database.refreshObjects() }) },
                    isSuperSet: setGroup.setType == .superSet,
                    navigationToDetailEnabled: true)
            }
            Spacer()
            if !isEditing {
                Menu(content: {
                    Section {
                        Button { database.convertSetGroupToStandardSets(setGroup) } label: {
                            Label(NSLocalizedString("normalset", comment: ""),
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
                        .padding([.vertical, .trailing])
                }
                .textCase(.none)
            }
        }
        .font(.title3.weight(.bold))
        .foregroundColor(.label)
        .padding(.vertical, 10)
        .padding(.horizontal, isEditing ? 15 : 0)
    }
    
}
