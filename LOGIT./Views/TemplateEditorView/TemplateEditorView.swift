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
                        setGroupHeader(for: setGroup)
                            .deleteDisabled(true)
                    } else {
                        setGroupCellWithSets(for: setGroup)
                    }
                }
                .onMove(perform: moveSetGroups)
                .listRowInsets(EdgeInsets())
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
            .scrollIndicators(.hidden)
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
    
    @ViewBuilder
    private func setGroupCellWithSets(for setGroup: TemplateSetGroup) -> some View {
        Section {
            if !isEditing {
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
                ForEach(setGroup.sets, id:\.objectID) { templateSet in
                    templateSetCell(templateSet: templateSet)
                        .listRowSeparator(.hidden, edges: .bottom)
                }
                .onDelete { indexSet in
                    setGroup.sets.elements(for: indexSet).forEach { database.delete($0) }
                    database.refreshObjects()
                }
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    database.addSet(to: setGroup)
                } label: {
                    Label(NSLocalizedString("addSet", comment: ""),
                          systemImage: "plus.circle.fill")
                        .foregroundColor(setGroup.exercise?.muscleGroup?.color)
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.fill)
            }
        } header: {
            setGroupHeader(for: setGroup)
        }
        .listRowInsets(EdgeInsets())
        .buttonStyle(.plain)
        .accentColor(setGroup.exercise?.muscleGroup?.color ?? .accentColor)
    }
    
    private func setGroupHeader(for setGroup: TemplateSetGroup) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(template.setGroups.firstIndex(of: setGroup)! + 1) / \(template.setGroups.count)  ·  \(setGroup.sets.count) \(NSLocalizedString("set" + (setGroup.sets.count == 1 ? "" : "s"), comment: ""))")
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
                        Button { database.convertSetGroupToSuperSet(setGroup) } label: {
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
        TemplateEditorView(template: Database.preview.testTemplate, isEditingExistingTemplate: true)
            .environmentObject(Database.preview)
    }
}
