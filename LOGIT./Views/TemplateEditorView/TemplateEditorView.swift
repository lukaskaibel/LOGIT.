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
        var id: UUID { UUID() }
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
            List {
                if !isEditing {
                    Section {
                        TextField(NSLocalizedString("title", comment: ""), text: templateName, axis: .vertical)
                            .font(.largeTitle.weight(.bold))
                            .lineLimit(2)
                    }.listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                ForEach(template.setGroups, id:\.objectID) { setGroup in
                    if isEditing {
                        SetGroupCellForEditing(for: setGroup)
                            .listRowInsets(EdgeInsets())
                    } else {
                        SetGroupCellWithSets(for: setGroup)
                            .listRowInsets(EdgeInsets())
                    }
                }.onMove(perform: moveSetGroups)
                    .onDelete { template.setGroups.elements(for: $0).forEach { database.delete($0) } }
                if !isEditing {
                    Section {
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            sheetType = .exerciseSelection(exercise: nil,
                                                           setExercise: { database.newTemplateSetGroup(createFirstSetAutomatically: true,
                                                                                                       exercise: $0,
                                                                                                       template: template)
                                database.refreshObjects()
                            })
                        } label: {
                            Label(NSLocalizedString("addExercise", comment: ""), systemImage: "plus.circle.fill")
                        }
                        .listButton()
                    }
                }
                Spacer(minLength: 50)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .offset(x: 0, y: -30)
            .edgesIgnoringSafeArea(.bottom)
            .interactiveDismissDisabled()
            .navigationTitle(isEditingExistingTemplate ? NSLocalizedString("editTemplate", comment: "") : NSLocalizedString("newTemplate", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        database.save()
                        dismiss()
                    }.font(.body.weight(.bold))
                        .disabled(template.name?.isEmpty ?? true)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        if !isEditingExistingTemplate {
                            template.sets.forEach { database.delete($0) }
                            database.delete(template, saveContext: true)
                        }
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("reorderExercises", comment: "")) {
                        isEditing.toggle()
                        editMode = isEditing ? .active : .inactive
                    }
                    .disabled(template.numberOfSetGroups == 0)
                    .font(.body.weight(.medium))
                }
            }
            .sheet(item: $sheetType) { style in
                switch style {
                case let .exerciseSelection(exercise, setExercise):
                    NavigationStack {
                        ExerciseSelectionView(selectedExercise: exercise, setExercise: setExercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                                        sheetType = nil
                                    }
                                }
                            }
                    }
                case let .exerciseDetail(exercise):
                    ExerciseDetailView(exercise: exercise)
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    // MARK: - Supporting Views
    
    private func SetGroupCellForEditing(for setGroup: TemplateSetGroup) -> some View {
        SetGroupHeader(for: setGroup)
            .buttonStyle(.plain)
            .accentColor(setGroup.exercise?.muscleGroup?.color ?? .accentColor)
    }
    
    @ViewBuilder
    private func SetGroupCellWithSets(for setGroup: TemplateSetGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SetGroupHeader(for: setGroup)
            ForEach(setGroup.sets, id:\.objectID) { templateSet in
                TemplateSetCell(for: templateSet)
                    .listRowSeparator(.hidden, edges: .bottom)
            }
            .onDelete { indexSet in
                setGroup.sets.elements(for: indexSet).forEach { database.delete($0) }
            }
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                database.addSet(to: setGroup)
            } label: {
                Label(NSLocalizedString("addSet", comment: ""), systemImage: "plus.circle.fill")
                    .foregroundColor(setGroup.exercise?.muscleGroup?.color)
                    .font(.body.weight(.bold))
            }
        }
        .buttonStyle(.plain)
        .accentColor(setGroup.exercise?.muscleGroup?.color ?? .accentColor)
    }
    
    private func SetGroupHeader(for setGroup: TemplateSetGroup) -> some View {
        HStack {
            if let muscleGroup = setGroup.exercise?.muscleGroup {
                if setGroup.setType == .superSet, let secondaryMuscleGroup = setGroup.secondaryExercise?.muscleGroup {
                    ColorMeter(items: [ColorMeter.Item(color: muscleGroup.color, amount: 1),
                                       ColorMeter.Item(color: secondaryMuscleGroup.color, amount: 1)])
                } else {
                    ColorMeter(items: [ColorMeter.Item(color: muscleGroup.color, amount: 1)])
                }
            }
            VStack(spacing: 5) {
                HStack {
                    Button {
                        sheetType = .exerciseSelection(exercise: setGroup.exercise,
                                                        setExercise: { setGroup.exercise = $0; database.refreshObjects() })
                    } label: {
                        HStack {
                            if setGroup.setType == .superSet {
                                Image(systemName: "1.circle")
                            }
                            Text(setGroup.exercise?.name ?? "")
                                .lineLimit(1)
                                .font(.title3.weight(.semibold))
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundColor(setGroup.exercise?.muscleGroup?.color)
                    }
                    Spacer()
                    Menu(content: {
                        Section {
                            Button(action: {
                                database.convertSetGroupToStandardSets(setGroup)
                            }) {
                                Label(NSLocalizedString("normalset", comment: ""),
                                      systemImage: setGroup.setType == .standard ? "checkmark" : "")
                            }
                            Button(action: {
                                database.convertSetGroupToTemplateSuperSet(setGroup)
                            }) {
                                Label(NSLocalizedString("superset", comment: ""),
                                      systemImage: setGroup.setType == .superSet ? "checkmark" : "")
                            }
                            Button(action: {
                                database.convertSetGroupToTemplateDropSets(setGroup)
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
                if setGroup.setType == .superSet {
                    HStack {
                        Image(systemName: "arrow.turn.down.right")
                            .padding(.leading)
                        Button {
                            sheetType = .exerciseSelection(exercise: setGroup.secondaryExercise,
                                                            setExercise: { setGroup.secondaryExercise = $0; database.refreshObjects() })
                        } label: {
                            HStack {
                                Image(systemName: "2.circle")
                                Text(setGroup.secondaryExercise?.name ?? "Select second exercise")
                                    .font(.title3.weight(.semibold))
                                    .lineLimit(1)
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.semibold))
                            }
                            .foregroundColor(setGroup.secondaryExercise?.muscleGroup?.color)
                        }
                        Spacer()
                    }
                }
                
            }
            .padding(.vertical, 5)
        }
        .padding(CELL_PADDING)
    }
    
    @ViewBuilder
    private func TemplateSetCell(for templateSet: TemplateSet) -> some View {
        HStack {
            Text(String((templateSet.setGroup?.sets.firstIndex(of: templateSet) ?? 0) + 1))
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
        }.padding(.trailing)
    }
    
    // MARK: - Supporting Methods
    
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
        TemplateEditorView(template: Database.preview.testTemplate, isEditingExistingTemplate: true)
            .environmentObject(Database.preview)
    }
}
