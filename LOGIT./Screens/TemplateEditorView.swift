//
//  TemplateEditorView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import SwiftUI

struct TemplateEditorView: View {
    
    enum SheetType: Identifiable {
        case exerciseSelection(exercise: Exercise?, setExercise: (Exercise) -> Void)
        case exerciseDetail(exercise: Exercise)
        var id: Int { switch self { case .exerciseSelection: return 0; case .exerciseDetail: return 1 } }
    }
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @StateObject var template: Template
    
    @State private var editMode: EditMode = .inactive
    @State private var isEditing: Bool = false
    @State private var sheetType: SheetType? = nil
    
    // MARK: - Parameters
    
    let isEditingExistingTemplate: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if isEditing {
                    List {
                        ForEach(template.setGroups, id:\.objectID) { setGroup in
                            TemplateSetGroupCell(
                                setGroup: setGroup,
                                focusedIntegerFieldIndex: .constant(nil),
                                sheetType: $sheetType,
                                isReordering: $isEditing,
                                supplementaryText: "\(template.setGroups.firstIndex(of: setGroup)! + 1) / \(template.setGroups.count)  ·  \(setGroup.setType.description)"
                            )
                            .padding(CELL_PADDING)
                            .tileStyle()
                            .padding(.top, template.setGroups.first == setGroup ? 0 : CELL_SPACING / 2)
                            .padding(.bottom, template.setGroups.last == setGroup ? 0 : CELL_SPACING / 2)
                            .padding(.horizontal)
                            .buttonStyle(.plain)
                        }
                        .onMove(perform: moveSetGroups)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                } else {
                    ScrollView {
                        VStack {
                            TextField(NSLocalizedString("title", comment: ""), text: templateName, axis: .vertical)
                                .font(.largeTitle.weight(.bold))
                                .lineLimit(2)
                                .padding(.vertical)
                                
                            VStack(spacing: SECTION_SPACING) {
                                ForEach(template.setGroups, id:\.objectID) { setGroup in
                                    TemplateSetGroupCell(
                                        setGroup: setGroup,
                                        focusedIntegerFieldIndex: .constant(nil),
                                        sheetType: $sheetType,
                                        isReordering: $isEditing,
                                        supplementaryText: "\(template.setGroups.firstIndex(of: setGroup)! + 1) / \(template.setGroups.count)  ·  \(setGroup.setType.description)"
                                    )
                                    .padding(CELL_PADDING)
                                    .tileStyle()
                                }
                            }
                            
                            addExerciseButton
                                .padding(.vertical, 30)
                        }
                        .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
                        .padding(.horizontal)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .interactiveDismissDisabled()
            .navigationTitle(isEditingExistingTemplate ? NSLocalizedString("editTemplate", comment: "") : NSLocalizedString("newTemplate", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        database.save()
                        dismiss()
                    }
                    .font(.body.weight(.bold))
                    .disabled(template.name?.isEmpty ?? true)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        if !isEditingExistingTemplate {
                            template.sets.forEach { database.delete($0) }
                            template.workouts.forEach { $0.template = nil }
                            database.delete(template, saveContext: true)
                        }
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Text("\(template.setGroups.count) \(NSLocalizedString("exercise\(template.setGroups.count == 1 ? "" : "s")", comment: ""))")
                        .font(.caption)
                    Spacer()
                    Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("edit", comment: "")) {
                        isEditing.toggle()
                        editMode = isEditing ? .active : .inactive
                    }
                    .disabled(template.numberOfSetGroups == 0)
                    .font(.body.weight(.medium))
                }
            }
            .sheet(item: $sheetType) { style in
                NavigationStack {
                    switch style {
                    case let .exerciseSelection(exercise, setExercise):
                        ExerciseSelectionView(selectedExercise: exercise, setExercise: setExercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                                        sheetType = nil
                                    }
                                }
                            }
                    case let .exerciseDetail(exercise):
                        ExerciseDetailView(exercise: exercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("dismiss", comment: ""), role: .cancel) {
                                        sheetType = nil
                                    }
                                }
                            }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    // MARK: - Supporting Views
    
    private var addExerciseButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            sheetType = .exerciseSelection(exercise: nil, setExercise: { exercise in
                database.newTemplateSetGroup(createFirstSetAutomatically: true,
                                            exercise: exercise,
                                            template: template)
                database.refreshObjects()
            })
        } label: {
            Label(NSLocalizedString("addExercise", comment: ""), systemImage: "plus.circle.fill")
                .bigButton()
        }
    }
    
    // MARK: - Computed Properties
    
    private var templateName: Binding<String> {
        Binding(get: { template.name ?? "" }, set: { template.name = $0 })
    }
    
    public func moveSetGroups(from source: IndexSet, to destination: Int) {
        template.setGroups.move(fromOffsets: source, toOffset: destination)
        database.refreshObjects()
    }
    
    
    
}

struct TemplateEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TemplateEditorView(
                template: Database.preview.testTemplate,
                isEditingExistingTemplate: true
            )
        }
        .environmentObject(Database.preview)
    }
}
