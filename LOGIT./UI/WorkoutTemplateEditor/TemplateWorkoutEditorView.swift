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
    @StateObject private var exerciseSelection = ExerciseSelection(context: Database.shared.container.viewContext)
    
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
        }
    }
    
    private func SetGroupCellForEditing(for setGroup: TemplateWorkoutSetGroup) -> some View {
        SetGroupHeader(for: setGroup)
    }
    
    private func SetGroupCellWithSets(for setGroup: TemplateWorkoutSetGroup) -> some View {
        Section {
            SetGroupHeader(for: setGroup)
            ForEach(setGroup.sets?.array as? [TemplateWorkoutSet] ?? .emptyList, id:\.objectID) { templateSet in
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
        }.padding(.vertical, 8)
    }
    
    private func TemplateWorkoutSetCell(for workoutSet: TemplateWorkoutSet) -> some View {
        var repetitionsString: Binding<String> {
            Binding<String>(
                get: { workoutSet.repetitions == 0 ? "" : String(workoutSet.repetitions) },
                set: {
                    value in workoutSet.repetitions = NumberFormatter().number(from: value)?.int64Value ?? 0
                    templateWorkoutEditor.updateView()
                }
            )
        }
        
        var weightString: Binding<String> {
            Binding<String>(
                get: { workoutSet.weight == 0 ? "" : String(convertWeightForDisplaying(workoutSet.weight)) },
                set: {
                    value in workoutSet.weight = convertWeightForStoring(NumberFormatter().number(from: value)?.int64Value ?? 0)
                    templateWorkoutEditor.updateView()
                }
            )
        }
        
        return HStack {
            Text(String((templateWorkoutEditor.indexInSetGroup(for: workoutSet) ?? 0) + 1))
                .foregroundColor(.secondaryLabel)
                .font(.body.monospacedDigit())
                .padding(.horizontal, 8)
            TextField("0", text: repetitionsString)
                .keyboardType(.numberPad)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(7)
                .background(colorScheme == .light ? Color.secondaryBackground : .background)
                .cornerRadius(7)
                .overlay {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(workoutSet.repetitions == 0 ? .secondaryLabel : .label)
                            .font(.caption.weight(.bold))
                            .padding(7)
                        Spacer()
                    }
                }
            TextField("0", text: weightString)
                .keyboardType(.numberPad)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(7)
                .background(colorScheme == .light ? Color.secondaryBackground : .background)
                .cornerRadius(7)
                .overlay {
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(workoutSet.weight == 0 ? .secondaryLabel : .label)
                            .font(.caption.weight(.bold))
                            .padding(7)
                        Spacer()
                    }
                }
        }
    }

    
}

struct WorkoutTemplateEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor())
    }
}
