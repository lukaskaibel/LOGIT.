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
                ForEach(templateWorkoutEditor.templateWorkout.setGroups?.array as? [TemplateWorkoutSetGroup] ?? .emptyList, id:\.objectID) { setGroup in
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
                .sheet(isPresented: $showingExerciseSelection, onDismiss: { templateWorkoutEditor.setGroupWithSelectedExercise = nil }) {
                    NavigationView {
                        ExerciseSelectionView(exerciseSelection: exerciseSelection,
                                              selectedExercise: Binding(get: { templateWorkoutEditor.setGroupWithSelectedExercise?.exercise }, set: {
                            if let exercise = $0 {
                                if let setGroup = templateWorkoutEditor.setGroupWithSelectedExercise {
                                    setGroup.exercise = exercise
                                } else {
                                    templateWorkoutEditor.addSetGroup(for: exercise)
                                }
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
            ForEach(setGroup.sets?.array as? [TemplateSet] ?? .emptyList, id:\.objectID) { templateSet in
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
        HStack {
            Button(action: {
                templateWorkoutEditor.setGroupWithSelectedExercise = setGroup
                showingExerciseSelection = true
            }) {
                HStack {
                    Text(setGroup.exercise?.name ?? "")
                        .fontWeight(.medium)
                        .foregroundColor(.label)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondaryLabel)
                        .font(.caption.weight(.semibold))
                }
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

        }.padding(.vertical, 8)
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
            } else {
                EmptyView()
                fatalError("SuperSet Cell not implemented.")
            }
        }
    }
    
}

struct WorkoutTemplateEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor())
    }
}
