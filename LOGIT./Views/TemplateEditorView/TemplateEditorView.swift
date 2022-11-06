//
//  TemplateEditorView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import SwiftUI

struct TemplateEditorView: View {
    
    enum SheetStyle {
        case exerciseSelection(exercise: Exercise?, setExercise: (Exercise) -> Void)
    }
    
    // MARK: -
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var templateEditor: TemplateEditor
    
    @State private var editMode: EditMode = .inactive
    @State private var isEditing: Bool = false
    @State private var showingExerciseSelection = false
    
    var body: some View {
        NavigationView {
            List {
                if !isEditing {
                    Section {
                        TextField(NSLocalizedString("title", comment: ""), text: $templateEditor.templateName)
                            .font(.body.weight(.bold))
                            .padding(.vertical, 8)
                    }
                }
                ForEach(templateEditor.template.setGroups, id:\.objectID) { setGroup in
                    if isEditing {
                        SetGroupCellForEditing(for: setGroup)
                    } else {
                        SetGroupCellWithSets(for: setGroup)
                    }
                }.onMove(perform: templateEditor.moveSetGroups)
                    .onDelete { indexSet in templateEditor.delete(setGroupWithIndexes: indexSet) }
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
                .navigationTitle(templateEditor.isEditingExistingTemplate ? NSLocalizedString("editTemplate", comment: "") : NSLocalizedString("newTemplate", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(NSLocalizedString("save", comment: "")) {
                            templateEditor.saveTemplate()
                            dismiss()
                        }.font(.body.weight(.bold))
                            .disabled(!templateEditor.canSaveTemplate)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(NSLocalizedString("cancel", comment: "")) {
                            if !templateEditor.isEditingExistingTemplate {
                                templateEditor.deleteTemplate()
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
                            }.disabled(templateEditor.template.numberOfSetGroups == 0)
                                .font(.body.weight(.medium))
                        }
                    }
                }
                .sheet(isPresented: $showingExerciseSelection,
                       onDismiss: { templateEditor.setGroupWithSelectedExercise = nil; templateEditor.isSelectingSecondaryExercise = false }) {
                    NavigationView {
                        /*
                        ExerciseSelectionView(selectedExercise: <#T##Exercise?#>, setExercise: <#T##(Exercise) -> Void#>)
                        ExerciseSelectionView(selectedExercise: Binding(get: {
                            guard let setGroup = templateEditor.setGroupWithSelectedExercise else { return nil }
                            return templateEditor.isSelectingSecondaryExercise ? setGroup.secondaryExercise : setGroup.exercise
                        }, set: {
                            guard let exercise = $0 else { return }
                            guard let setGroup = templateEditor.setGroupWithSelectedExercise else { templateEditor.addSetGroup(for: exercise); return }
                            if templateEditor.isSelectingSecondaryExercise {
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
                         */
                    }
                }
                .onAppear {
                    UIScrollView.appearance().keyboardDismissMode = .interactive
                }
        }.environmentObject(templateEditor)
    }
    
    private func SetGroupCellForEditing(for setGroup: TemplateSetGroup) -> some View {
        SetGroupHeader(for: setGroup)
    }
    
    private func SetGroupCellWithSets(for setGroup: TemplateSetGroup) -> some View {
        Section {
            SetGroupHeader(for: setGroup)
            ForEach(setGroup.sets, id:\.objectID) { templateSet in
                TemplateSetCell(for: templateSet)
                    .listRowSeparator(.hidden, edges: .bottom)
            }.onDelete { indexSet in
                templateEditor.delete(setsWithIndices: indexSet, in: setGroup)
            }
            Button(action: {
                templateEditor.addSet(to: setGroup)
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text(NSLocalizedString("addSet", comment: ""))
                    Spacer()
                }
            }.padding(.vertical, 8)
        }
    }
    
    private func SetGroupHeader(for setGroup: TemplateSetGroup) -> some View {
        VStack(spacing: 5) {
            HStack {
                Button(action: {
                    templateEditor.setGroupWithSelectedExercise = setGroup
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
                            templateEditor.convertSetGroupToStandardSets(setGroup)
                        }) {
                            Label(NSLocalizedString("normalset", comment: ""),
                                  systemImage: setGroup.setType == .standard ? "checkmark" : "")
                        }
                        Button(action: {
                            templateEditor.convertSetGroupToTemplateSuperSet(setGroup)
                        }) {
                            Label(NSLocalizedString("superset", comment: ""),
                                  systemImage: setGroup.setType == .superSet ? "checkmark" : "")
                        }
                        Button(action: {
                            templateEditor.convertSetGroupToTemplateDropSets(setGroup)
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
                        templateEditor.setGroupWithSelectedExercise = setGroup
                        templateEditor.isSelectingSecondaryExercise = true
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
    private func TemplateSetCell(for templateSet: TemplateSet) -> some View {
        HStack {
            Text(String((templateEditor.indexInSetGroup(for: templateSet) ?? 0) + 1))
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

struct TemplateEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateEditorView(templateEditor: TemplateEditor())
    }
}
