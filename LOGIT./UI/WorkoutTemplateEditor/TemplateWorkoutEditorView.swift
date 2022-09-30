//
//  WorkoutTemplateEditorView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import SwiftUI

struct TemplateWorkoutEditorView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var templateWorkoutEditor: TemplateWorkoutEditor
    @StateObject private var exerciseSelection = ExerciseSelection()
    
    @State private var editMode: EditMode = .inactive
    @State private var isEditing: Bool = false
    @State private var showingExerciseSelection = false
    
    var body: some View {
        NavigationView {
            List {
                if !isEditing {
                    Section {
                        TextField(NSLocalizedString("title", comment: ""), text: $templateWorkoutEditor.templateWorkoutName)
                            .font(.body.weight(.bold))
                            .padding(.vertical, 8)
                    }
                }
                ForEach(templateWorkoutEditor.templateWorkout.setGroups, id:\.objectID) { setGroup in
                    if isEditing {
                        SetGroupCellForEditing(for: setGroup)
                    } else {
                        SetGroupCellWithSets(for: setGroup)
                    }
                }.onMove(perform: templateWorkoutEditor.moveSetGroups)
                    .onDelete { indexSet in templateWorkoutEditor.delete(setGroupWithIndexes: indexSet) }
                if !isEditing {
                    Section {
                        Button(action: { showingExerciseSelection = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(NSLocalizedString("addExercise", comment: ""))
                            }.padding(.vertical, 8)
                        }
                    }
                }
            }.listStyle(.insetGrouped)
                .interactiveDismissDisabled()
                .navigationTitle(templateWorkoutEditor.isEditingExistingTemplate ? NSLocalizedString("editWorkoutTemplate", comment: "") : NSLocalizedString("newWorkoutTemplate", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(NSLocalizedString("save", comment: "")) {
                            templateWorkoutEditor.saveTemplateWorkout()
                            dismiss()
                        }.font(.body.weight(.bold))
                            .disabled(!templateWorkoutEditor.canSaveTemplate)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(NSLocalizedString("cancel", comment: "")) {
                            if !templateWorkoutEditor.isEditingExistingTemplate {
                                templateWorkoutEditor.deleteTemplateWorkout()
                            }
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button(NSLocalizedString("done", comment: "")) { hideKeyboard() }
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Spacer()
                            Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("reorderExercises", comment: "")) {
                                isEditing.toggle()
                                editMode = isEditing ? .active : .inactive
                            }.disabled(templateWorkoutEditor.templateWorkout.numberOfSetGroups == 0)
                                .font(.body.weight(.medium))
                        }
                    }
                }
                .sheet(isPresented: $showingExerciseSelection,
                       onDismiss: { templateWorkoutEditor.setGroupWithSelectedExercise = nil; templateWorkoutEditor.isSelectingSecondaryExercise = false }) {
                    NavigationView {
                        ExerciseSelectionView(exerciseSelection: exerciseSelection,
                                              selectedExercise: Binding(get: {
                            guard let setGroup = templateWorkoutEditor.setGroupWithSelectedExercise else { return nil }
                            return templateWorkoutEditor.isSelectingSecondaryExercise ? setGroup.secondaryExercise : setGroup.exercise
                        }, set: {
                            guard let exercise = $0 else { return }
                            guard let setGroup = templateWorkoutEditor.setGroupWithSelectedExercise else { templateWorkoutEditor.addSetGroup(for: exercise); return }
                            if templateWorkoutEditor.isSelectingSecondaryExercise {
                                setGroup.secondaryExercise = exercise
                            } else {
                                setGroup.exercise = exercise
                            }
                        }))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                                    showingExerciseSelection = false
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    UIScrollView.appearance().keyboardDismissMode = .interactive
                }
        }.environmentObject(templateWorkoutEditor)
    }
    
    private func SetGroupCellForEditing(for setGroup: TemplateWorkoutSetGroup) -> some View {
        SetGroupHeader(for: setGroup)
    }
    
    private func SetGroupCellWithSets(for setGroup: TemplateWorkoutSetGroup) -> some View {
        Section {
            SetGroupHeader(for: setGroup)
            ForEach(setGroup.sets, id:\.objectID) { templateSet in
                TemplateWorkoutSetCell(for: templateSet)
                    .listRowSeparator(.hidden, edges: .bottom)
            }.onDelete { indexSet in
                templateWorkoutEditor.delete(setsWithIndices: indexSet, in: setGroup)
            }
            Button(action: {
                templateWorkoutEditor.addSet(to: setGroup)
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text(NSLocalizedString("addSet", comment: ""))
                    Spacer()
                }
            }.padding(.vertical, 8)
        }
    }
    
    private func SetGroupHeader(for setGroup: TemplateWorkoutSetGroup) -> some View {
        VStack(spacing: 5) {
            HStack {
                Button(action: {
                    templateWorkoutEditor.setGroupWithSelectedExercise = setGroup
                    showingExerciseSelection = true
                }) {
                    HStack {
                        if setGroup.setType == .superSet {
                            Image(systemName: "1.circle")
                        }
                        Text(setGroup.exercise?.name ?? "")
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }.foregroundColor(setGroup.exercise == nil ? .secondaryLabel : .label)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.tertiaryFill)
                        .cornerRadius(5)
                }
                Spacer()
                Menu(content: {
                    Section {
                        Button(action: {
                            templateWorkoutEditor.convertSetGroupToStandardSets(setGroup)
                        }) {
                            Label(NSLocalizedString("normalset", comment: ""),
                                  systemImage: setGroup.setType == .standard ? "checkmark" : "")
                        }
                        Button(action: {
                            templateWorkoutEditor.convertSetGroupToTemplateSuperSet(setGroup)
                        }) {
                            Label(NSLocalizedString("superset", comment: ""),
                                  systemImage: setGroup.setType == .superSet ? "checkmark" : "")
                        }
                        Button(action: {
                            templateWorkoutEditor.convertSetGroupToTemplateDropSets(setGroup)
                        }) {
                            Label(NSLocalizedString("dropset", comment: ""),
                                  systemImage: setGroup.setType == .dropSet ? "checkmark" : "")
                        }
                    }
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.label)
                        .padding(7)
                }
            }
            if setGroup.setType == .superSet {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .padding(.leading)
                    Button(action: {
                        templateWorkoutEditor.setGroupWithSelectedExercise = setGroup
                        templateWorkoutEditor.isSelectingSecondaryExercise = true
                        showingExerciseSelection = true
                    }) {
                        HStack {
                            Image(systemName: "2.circle")
                            Text(setGroup.secondaryExercise?.name ?? "Select second exercise")
                                .fontWeight(.medium)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }.foregroundColor(setGroup.secondaryExercise == nil ? .secondaryLabel : .label)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.tertiaryFill)
                            .cornerRadius(5)
                    }
                    Spacer()
                }
            }

        }.padding(.vertical, 8)
            .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func TemplateWorkoutSetCell(for templateSet: TemplateSet) -> some View {
        HStack {
            Text(String((templateWorkoutEditor.indexInSetGroup(for: templateSet) ?? 0) + 1))
                .foregroundColor(.secondaryLabel)
                .font(.body.monospacedDigit())
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
            if let templateStandardSet = templateSet as? TemplateStandardSet {
                TemplateStandardSetCell(for: templateStandardSet)
            } else if let templateDropSet = templateSet as? TemplateDropSet {
                TemplateDropSetCell(for: templateDropSet)
                    .padding(.top, 8)
            } else if let templateSuperSet = templateSet as? TemplateSuperSet {
                TemplateSuperSetCell(for: templateSuperSet)
                    .padding(.top, 8)
            }
        }
    }
    
}

struct WorkoutTemplateEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor())
    }
}
