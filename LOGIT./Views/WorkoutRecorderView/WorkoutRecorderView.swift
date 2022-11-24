//
//  WorkoutRecorderView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import SwiftUI
import UIKit
import CoreData

struct WorkoutRecorderView: View {

    enum SheetType: Identifiable {
        case exerciseDetail(exercise: Exercise)
        case exerciseSelection(exercise: Exercise?, setExercise: (Exercise) -> Void)
        var id: Int { switch self { case .exerciseDetail: return 0; case .exerciseSelection: return 1 } }
    }
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.goHome) var goHome
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @StateObject var workout: Workout
    
    @State internal var isEditing: Bool = false
    @State private var editMode: EditMode = .inactive
    
    @State internal var sheetType: SheetType?
    
    @State internal var workoutSetTemplateSetDictionary = [WorkoutSet:TemplateSet]()
    
    @State private var showingTimerView = false
    
    @State private var isShowingFinishConfirmation = false
    
    // MARK: - Variables
    
    let template: Template?
    
    // MARK: - Body
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                Divider()
                exerciseList
            }
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: { showingTimerView.toggle() }) {
                        TimerTimeView(showingTimerView: $showingTimerView)
                    }.font(.body.monospacedDigit())
                    Spacer()
                    Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("reorderExercises", comment: "")) {
                        isEditing.toggle()
                        editMode = isEditing ? .active : .inactive
                    }.disabled(workout.numberOfSetGroups == 0)
                }
            }
            .sheet(item: $sheetType) { type in
                NavigationStack {
                    switch type {
                    case let .exerciseDetail(exercise):
                        ExerciseDetailView(exercise: exercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("dismiss", comment: "")) { sheetType = nil }
                                }
                            }
                            .tag("detail")
                    case let .exerciseSelection(exercise, setExercise):
                        ExerciseSelectionView(selectedExercise: exercise, setExercise: setExercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) { sheetType = nil }
                                }
                            }
                            .tag("selection")
                    }
                }
            }
            .confirmationDialog(Text(workout.allSetsHaveEntries ? NSLocalizedString("finishWorkoutConfimation", comment: "") :
                                        !workout.hasEntries ? NSLocalizedString("noEntriesConfirmation", comment: "") :
                                        NSLocalizedString("deleteSetsWithoutEntries", comment: "")),
                                isPresented: $isShowingFinishConfirmation,
                                titleVisibility: .visible) {
                Button(workout.allSetsHaveEntries ? NSLocalizedString("finishWorkout", comment: "") :
                        !workout.hasEntries ? NSLocalizedString("noEntriesConfirmation", comment: "") :
                        NSLocalizedString("deleteSets", comment: "")) {
                    workout.sets.filter({ !$0.hasEntry }).forEach { database.delete($0) }
                    if workout.isEmpty { database.delete(workout, saveContext: true) }
                    else { saveWorkout() }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                    goHome()
                }.font(.body.weight(.semibold))
                Button("Continue Workout", role: .cancel) {}
            }
        }.onAppear {
            if let template = template {
                updateWorkout(with: template)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var header: some View {
        VStack(spacing: 5) {
            WorkoutDurationView()
            HStack {
                TextField(Workout.getStandardName(for: Date()), text: workoutName, axis: .vertical)
                    .lineLimit(2)
                    .foregroundColor(.label)
                    .font(.title2.weight(.bold))
                Spacer()
                Button(action: {
                    if !workout.hasEntries {
                        deleteWorkout()
                        dismiss()
                    } else {
                        isShowingFinishConfirmation = true
                    }
                }) {
                    Image(systemName: !workout.hasEntries ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(!workout.hasEntries ? .separator : .accentColor)
                        .font(.title)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(colorScheme == .light ? Color.tertiaryBackground : .secondaryBackground)
    }
        
    private var exerciseList: some View {
        List {
            ForEach(workout.setGroups, id:\.objectID) { setGroup in
                if isEditing {
                    exerciseHeader(setGroup: setGroup)
                        .deleteDisabled(true)
                } else {
                    setGroupCell(for: setGroup)
                }
            }
            .onMove(perform: moveSetGroups)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            if !isEditing {
                AddExerciseButton
            }
        }.listStyle(.insetGrouped)
    }
    
    private var AddExerciseButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            sheetType = .exerciseSelection(exercise: nil, setExercise: { exercise in
                database.newWorkoutSetGroup(createFirstSetAutomatically: true,
                                            exercise: exercise,
                                            workout: workout)
                database.refreshObjects()
            })
        } label: {
            Label(NSLocalizedString("addExercise", comment: ""), systemImage: "plus.circle.fill")
        }
        .listButton()
    }
    
    // MARK: - Computed Properties
    
    private var workoutName: Binding<String> {
        Binding(get: { workout.name ?? "" }, set: { workout.name = $0 })
    }
    
    private func moveSetGroups(from source: IndexSet, to destination: Int) {
        workout.setGroups.move(fromOffsets: source, toOffset: destination)
        database.refreshObjects()
    }
    
    internal func indexInSetGroup(for workoutSet: WorkoutSet) -> Int? {
        for setGroup in workout.setGroups {
            if let index = setGroup.index(of: workoutSet) {
                return index
            }
        }
        return nil
    }
    
    private func updateWorkout(with template: Template){
        template.workouts.append(workout)
        workout.name = template.name
        for templateSetGroup in template.setGroups {
            let setGroup = database.newWorkoutSetGroup(createFirstSetAutomatically: false,
                                                       exercise: templateSetGroup.exercise,
                                                       workout: workout)
            templateSetGroup.sets
                .forEach { templateSet in
                    if let templateStandardSet = templateSet as? TemplateStandardSet {
                        let standardSet = database.newStandardSet(setGroup: setGroup)
                        workoutSetTemplateSetDictionary[standardSet] = templateStandardSet
                    } else if let templateDropSet = templateSet as? TemplateDropSet {
                        let dropSet = database.newDropSet(from: templateDropSet, setGroup: setGroup)
                        workoutSetTemplateSetDictionary[dropSet] = templateDropSet
                    } else if let templateSuperSet = templateSet as? TemplateSuperSet {
                        let superSet = database.newSuperSet(from: templateSuperSet, setGroup: setGroup)
                        workoutSetTemplateSetDictionary[superSet] = templateSuperSet
                    }
                }
        }
        database.refreshObjects()
    }
    
    private func saveWorkout() {
        if workout.name?.isEmpty ?? true {
            workout.name = Workout.getStandardName(for: workout.date!)
        }
        workout.endDate = .now
        database.save()
    }
    
    private func deleteWorkout() {
        workout.sets.filter({ !$0.hasEntry }).forEach { database.delete($0) }
        database.delete(workout, saveContext: true)
    }
    
    // MARK: Placeholder Methods
    
    public func repetitionsPlaceholder(for standardSet: StandardSet) -> String {
        guard let templateStandardSet = workoutSetTemplateSetDictionary[standardSet] as? TemplateStandardSet else { return "0" }
        return String(templateStandardSet.repetitions)
    }
    
    public func weightPlaceholder(for standardSet: StandardSet) -> String {
        guard let templateStandardSet = workoutSetTemplateSetDictionary[standardSet] as? TemplateStandardSet else { return "0" }
        return String(convertWeightForDisplaying(templateStandardSet.weight))
    }
    
    public func repetitionsPlaceholder(for dropSet: DropSet) -> [String] {
        guard let templateDropSet = workoutSetTemplateSetDictionary[dropSet] as? TemplateDropSet else { return ["0"] }
        return templateDropSet.repetitions?.map { String($0) } ?? .emptyList
    }
    
    public func weightsPlaceholder(for dropSet: DropSet) -> [String] {
        guard let templateDropSet = workoutSetTemplateSetDictionary[dropSet] as? TemplateDropSet else { return ["0"] }
        return templateDropSet.weights?.map { String(convertWeightForDisplaying($0)) } ?? .emptyList
    }
    
    public func repetitionsPlaceholder(for superSet: SuperSet) -> [String] {
        guard let templateSuperSet = workoutSetTemplateSetDictionary[superSet] as? TemplateSuperSet else { return ["0", "0"] }
        return [templateSuperSet.repetitionsFirstExercise, templateSuperSet.repetitionsSecondExercise]
            .map { String($0) }
    }
    
    public func weightsPlaceholder(for superSet: SuperSet) -> [String] {
        guard let templateSuperSet = workoutSetTemplateSetDictionary[superSet] as? TemplateSuperSet else { return ["0", "0"] }
        return [templateSuperSet.weightFirstExercise, templateSuperSet.weightSecondExercise]
            .map { String(convertWeightForDisplaying($0)) }
    }
    
}

struct WorkoutRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecorderView(workout: Database.preview.testWorkout, template: Database.preview.testTemplate)
            .environmentObject(Database.preview)
    }
}
