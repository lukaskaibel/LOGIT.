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
    
    // MARK: - AppStorage
    
    @AppStorage("preventAutoLock") var preventAutoLock: Bool = true
    
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
    @State internal var focusedIntegerFieldIndex: IntegerField.Index? = IntegerField.Index(primary: 0, secondary: 0, tertiary: 0)
    
    // MARK: - Variables
    
    let template: Template?
    
    // MARK: - Body
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                Divider()
                List {
                    ForEach(workout.setGroups, id:\.objectID) { setGroup in
                        if isEditing {
                            exerciseHeader(setGroup: setGroup)
                                .deleteDisabled(true)
                        } else {
                            setGroupCell(for: setGroup)
                                .environment(\.workoutSetTemplateSetDictionary, workoutSetTemplateSetDictionary)
                                .environment(\.setWorkoutEndDate, { workout.endDate = $0 })
                        }
                    }
                    .onMove(perform: moveSetGroups)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    Section {
                        if !isEditing {
                            addExerciseButton
                        }
                    }
                    Spacer(minLength: 30)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: { showingTimerView.toggle() }) {
                        TimerTimeView(showingTimerView: $showingTimerView)
                    }.font(.body.monospacedDigit())
                    Spacer()
                    Text("\(workout.setGroups.count) \(NSLocalizedString("exercise\(workout.setGroups.count == 1 ? "" : "s")", comment: ""))")
                        .font(.caption)
                    Spacer()
                    Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("edit", comment: "")) {
                        isEditing.toggle()
                        editMode = isEditing ? .active : .inactive
                    }.disabled(workout.numberOfSetGroups == 0)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if let workoutSet = selectedWorkoutSet {
                        if let _ = workoutSetTemplateSetDictionary[workoutSet] {
                            Button {
                                toggleSetCompleted(for: workoutSet)
                            } label: {
                                Image(systemName: "\(workoutSet.hasEntry ? "xmark" : "checkmark")")
                                    .keyboardToolbarButtonStyle()
                            }
                        } else {
                            Button {
                                toggleCopyPrevious(for: workoutSet)
                            } label: {
                                Image(systemName: "\(workoutSet.hasEntry ? "xmark" : "return.right")")
                                    .foregroundColor(!(workoutSet.previousSetInSetGroup?.hasEntry ?? false) && !workoutSet.hasEntry ? Color.placeholder : .primary)
                                    .keyboardToolbarButtonStyle()
                            }
                            .disabled(!(workoutSet.previousSetInSetGroup?.hasEntry ?? false) && !workoutSet.hasEntry)
                        }
                    }
                    HStack(spacing: 0) {
                        Button {
                             focusedIntegerFieldIndex = previousIntegerFieldIndex()
                        } label: {
                            Image(systemName: "arrowshape.turn.up.backward")
                                .keyboardToolbarButtonStyle()
                        }
                        .disabled(previousIntegerFieldIndex() == nil)
                        Button {
                             focusedIntegerFieldIndex = nextIntegerFieldIndex()
                        } label: {
                            Image(systemName: "arrowshape.turn.up.forward")
                                .keyboardToolbarButtonStyle()
                        }
                        .disabled(nextIntegerFieldIndex() == nil)
                    }
                    Button {
                        focusedIntegerFieldIndex = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .keyboardToolbarButtonStyle()
                    }
                    Spacer()
                }
            }
            .fullScreenCover(item: $sheetType) { type in
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
            .confirmationDialog(
                Text(
                    workout.allSetsHaveEntries ? NSLocalizedString("finishWorkoutConfimation", comment: "") :
                    !workout.hasEntries ? NSLocalizedString("noEntriesConfirmation", comment: "") :
                    NSLocalizedString("deleteSetsWithoutEntries", comment: "")
                ),
                isPresented: $isShowingFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button(
                    workout.allSetsHaveEntries ? NSLocalizedString("finishWorkout", comment: "") :
                    !workout.hasEntries ? NSLocalizedString("noEntriesConfirmation", comment: "") :
                    NSLocalizedString("deleteSets", comment: "")
                ) {
                    workout.sets.filter({ !$0.hasEntry }).forEach { database.delete($0) }
                    if workout.isEmpty { database.delete(workout, saveContext: true) }
                    else { saveWorkout() }
                    dismiss()
                    goHome()
                }
                .font(.body.weight(.semibold))
                Button(NSLocalizedString("continueWorkout", comment: ""), role: .cancel) {}
            }
        }
        .onAppear {
            if let template = template {
                updateWorkout(with: template)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            if preventAutoLock {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        #if targetEnvironment(simulator)
        .statusBarHidden(true)
        #endif
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
                ProgressCircleButton(progress: workout.setGroups.count > 0 ? progressInWorkout : 0.0) {
                    if !workout.hasEntries {
                        deleteWorkout()
                        dismiss()
                    } else {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        isShowingFinishConfirmation = true
                    }
                }
                .offset(y: -2)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(colorScheme == .light ? Color.tertiaryBackground : .secondaryBackground)
    }
    
    private var addExerciseButton: some View {
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
    
    // MARK: - Supporting Methods / Computed Properties
    
    private var workoutName: Binding<String> {
        Binding(get: { workout.name ?? "" }, set: { workout.name = $0 })
    }
    
    private func moveSetGroups(from source: IndexSet, to destination: Int) {
        workout.setGroups.move(fromOffsets: source, toOffset: destination)
        database.refreshObjects()
    }
    
    private var progressInWorkout: Float {
        Float((workout.sets.filter { $0.hasEntry }).count) / Float(workout.sets.count)
    }
    
    internal func indexInSetGroup(for workoutSet: WorkoutSet) -> Int? {
        for setGroup in workout.setGroups {
            if let index = setGroup.index(of: workoutSet) {
                return index
            }
        }
        return nil
    }
    
    internal var selectedWorkoutSet: WorkoutSet? {
        guard let focusedIndex = focusedIntegerFieldIndex else { return nil }
        return workout.sets.value(at: focusedIndex.primary)
    }
    
    internal func toggleCopyPrevious(for workoutSet: WorkoutSet) {
        if workoutSet.hasEntry {
            workoutSet.clearEntries()
        } else {
            guard let previousSet = workoutSet.previousSetInSetGroup else { return }
            workoutSet.match(previousSet)
        }
        database.refreshObjects()
    }
    
    internal func toggleSetCompleted(for workoutSet: WorkoutSet) {
        if let templateSet = workoutSetTemplateSetDictionary[workoutSet] {
            if workoutSet.hasEntry {
                workoutSet.clearEntries()
            } else {
                workoutSet.match(templateSet)
            }
            database.refreshObjects()
        }
    }
    
    private func nextIntegerFieldIndex() -> IntegerField.Index? {
        guard let focusedIndex = focusedIntegerFieldIndex,
                let focusedWorkoutSet = workout.sets.value(at: focusedIndex.primary) else { return nil }
        if focusedIndex.tertiary == 0 {
            return IntegerField.Index(primary: focusedIndex.primary, secondary: focusedIndex.secondary, tertiary: 1)
        }
        if let _ = focusedWorkoutSet as? SuperSet, focusedIndex.secondary == 0 {
            return IntegerField.Index(primary: focusedIndex.primary, secondary: 1, tertiary: 0)
        }
        if let focusedDropSet = focusedWorkoutSet as? DropSet, focusedIndex.secondary + 1 < focusedDropSet.numberOfDrops {
            return IntegerField.Index(primary: focusedIndex.primary, secondary: focusedIndex.secondary + 1, tertiary: 0)
        }
        guard workout.sets.value(at: focusedIndex.primary + 1) != nil else { return nil }
        return IntegerField.Index(primary: focusedIndex.primary + 1, secondary: 0, tertiary: 0)
    }
    
    private func previousIntegerFieldIndex() -> IntegerField.Index? {
        guard let focusedIndex = focusedIntegerFieldIndex,
                let focusedWorkoutSet = workout.sets.value(at: focusedIndex.primary) else { return nil }
        if focusedIndex.tertiary == 1 {
            return IntegerField.Index(primary: focusedIndex.primary, secondary: focusedIndex.secondary, tertiary: 0)
        }
        if let _ = focusedWorkoutSet as? SuperSet, focusedIndex.secondary == 1 {
            return IntegerField.Index(primary: focusedIndex.primary, secondary: 0, tertiary: 1)
        }
        if let _ = focusedWorkoutSet as? DropSet, focusedIndex.secondary - 1 >= 0 {
            return IntegerField.Index(primary: focusedIndex.primary, secondary: focusedIndex.secondary - 1, tertiary: 1)
        }
        guard let previousSet = workout.sets.value(at: focusedIndex.primary - 1) else { return nil }
        if let _ = previousSet as? StandardSet {
            return IntegerField.Index(primary: focusedIndex.primary - 1, secondary: 0, tertiary: 1)
        } else if let _ = previousSet as? SuperSet {
            return IntegerField.Index(primary: focusedIndex.primary - 1, secondary: 1, tertiary: 1)
        } else if let previousDropSet = previousSet as? DropSet {
            return IntegerField.Index(primary: focusedIndex.primary - 1, secondary: previousDropSet.numberOfDrops - 1, tertiary: 1)
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
        workout.setGroups.forEach {
            if $0.setType == .superSet && $0.secondaryExercise == nil {
                database.convertSetGroupToStandardSets($0)
            }
        }
        database.save()
    }
    
    private func deleteWorkout() {
        workout.sets.filter({ !$0.hasEntry }).forEach { database.delete($0) }
        database.delete(workout, saveContext: true)
    }
    
}

struct WorkoutRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecorderView(workout: Database.preview.testWorkout, template: Database.preview.testTemplate)
            .environmentObject(Database.preview)
    }
}


private struct WorkoutSetTemplateSetDictionaryKey: EnvironmentKey {
    static let defaultValue: [WorkoutSet:TemplateSet] = [WorkoutSet:TemplateSet]()
}

private struct SetWorkoutEndDateKey: EnvironmentKey {
    static let defaultValue: (Date) -> Void = { _ in }
}

extension EnvironmentValues {
    var workoutSetTemplateSetDictionary: [WorkoutSet:TemplateSet] {
        get { self[WorkoutSetTemplateSetDictionaryKey.self] }
        set { self[WorkoutSetTemplateSetDictionaryKey.self] = newValue }
    }
    var setWorkoutEndDate: (Date) -> Void {
        get { self[SetWorkoutEndDateKey.self] }
        set { self[SetWorkoutEndDateKey.self] = newValue }
    }
}
