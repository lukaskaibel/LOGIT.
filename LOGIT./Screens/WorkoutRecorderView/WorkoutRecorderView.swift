//
//  WorkoutRecorderView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import AVFoundation
import CoreData
import OSLog
import SwiftUI
import UIKit


struct WorkoutRecorderView: View {

    enum SheetType: Identifiable {
        case exerciseDetail(exercise: Exercise)
        case exerciseSelection(exercise: Exercise?, setExercise: (Exercise) -> Void)
        var id: Int { switch self { case .exerciseDetail: return 0; case .exerciseSelection: return 1 } }
    }
    
    // MARK: - AppStorage
    
    @AppStorage("preventAutoLock") var preventAutoLock: Bool = true
    @AppStorage("timerIsMuted") var timerIsMuted: Bool = false
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.goHome) var goHome
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @StateObject var workout: Workout
    @State internal var workoutSetTemplateSetDictionary = [WorkoutSet:TemplateSet]()
    
    @State internal var isEditing: Bool = false
    @State internal var editMode: EditMode = .inactive
    
    @StateObject var chronograph = Chronograph()
    @State internal var isShowingChronoView = false
    @State private var shouldShowChronoViewAgainWhenPossible = false
    @State private var isShowingChronoInHeader = false
    @State private var shouldFlash = false
    @State private var timerSound: AVAudioPlayer?
    
    @State private var isShowingFinishConfirmation = false
    @State internal var sheetType: SheetType?
    
    @State internal var focusedIntegerFieldIndex: IntegerField.Index?
    
    // MARK: - Variables
    
    let template: Template?
    
    // MARK: - Body
        
    var body: some View {
        NavigationStack {
            ZStack {
                if isEditing {
                    List {
                        Spacer(minLength: 90)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        ForEach(workout.setGroups, id:\.objectID) { setGroup in
                            WorkoutRecorderView.WorkoutSetGroupRecorderCell(
                                setGroup: setGroup,
                                focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                                sheetType: $sheetType,
                                isEditing: $isEditing,
                                editMode: $editMode
                            )
                            .padding(CELL_PADDING)
                            .tileStyle()
                            .padding(.top, workout.setGroups.first == setGroup ? 0 : CELL_SPACING / 2)
                            .padding(.bottom, workout.setGroups.last == setGroup ? 0 : CELL_SPACING / 2)
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
                        LazyVStack(spacing: SECTION_SPACING) {
                            ForEach(workout.setGroups, id:\.objectID) { setGroup in
                                WorkoutRecorderView.WorkoutSetGroupRecorderCell(
                                    setGroup: setGroup,
                                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                                    sheetType: $sheetType,
                                    isEditing: $isEditing,
                                    editMode: $editMode
                                )
                                .environment(\.workoutSetTemplateSetDictionary, workoutSetTemplateSetDictionary)
                                .environment(\.setWorkoutEndDate, { workout.endDate = $0 })
                                .padding(CELL_PADDING)
                                .tileStyle()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 90)
                        
                        AddExerciseButton
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                    }
                    .scrollIndicators(.hidden)
                }
                
                Header
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .overlay {
                if isShowingChronoView {
                    ChronoView(chronograph: chronograph)
                        .contentShape(Rectangle())
                        .onSwipeDown { withAnimation { isShowingChronoView = false } }
                        .background(.ultraThinMaterial)
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.8), radius: 20)
                        .padding(.bottom, CELL_SPACING)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItemsKeyboard
                ToolbarItemsBottomBar
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
        .overlay {
            FlashView(color: .accentColor, shouldFlash: $shouldFlash)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
        }
        .onChange(of: focusedIntegerFieldIndex) { newValue in
            if newValue == nil {
                isShowingChronoView = shouldShowChronoViewAgainWhenPossible
                shouldShowChronoViewAgainWhenPossible = false
            } else {
                shouldShowChronoViewAgainWhenPossible = shouldShowChronoViewAgainWhenPossible ? shouldShowChronoViewAgainWhenPossible : isShowingChronoView
                isShowingChronoView = false
            }
            withAnimation {
                isShowingChronoInHeader = chronograph.status != .idle && newValue != nil
            }
        }
        .onAppear {
            chronograph.onTimerFired =  {
                shouldFlash = true
                if !timerIsMuted {
                    playTimerSound()
                }
            }
            if preventAutoLock {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            if let template = template {
                updateWorkout(with: template)
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .scrollDismissesKeyboard(.interactively)
        #if targetEnvironment(simulator)
        .statusBarHidden(true)
        #endif
    }
    
    private var Header: some View {
        VStack(spacing: 0) {
            VStack(spacing: 5) {
                HStack {
                    WorkoutDurationView()
                    if isShowingChronoInHeader {
                        TimeStringView
                    }
                }
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
            .background(.ultraThinMaterial)
            Divider()
        }
    }
    
    internal var TimeStringView: some View {
        Text(remainingChronoTimeString)
            .foregroundColor(chronograph.status == .running ? .accentColor : .secondaryLabel)
            .font(.body.weight(.semibold).monospacedDigit())
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
        .bigButton()
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
    
    internal func nextIntegerFieldIndex() -> IntegerField.Index? {
        guard let focusedIndex = focusedIntegerFieldIndex,
                let focusedWorkoutSet = workout.sets.value(at: focusedIndex.primary) else { return nil }
        if let _ = focusedWorkoutSet as? StandardSet {
            guard focusedIndex.primary + 1 < workout.sets.count else { return nil }
            return IntegerField.Index(primary: focusedIndex.primary + 1, secondary: 0, tertiary: focusedIndex.tertiary)
        } else if let _ = focusedWorkoutSet as? SuperSet {
            guard focusedIndex.secondary == 1 else { return IntegerField.Index(primary: focusedIndex.primary,
                                                                               secondary: 1,
                                                                               tertiary: focusedIndex.tertiary) }
            guard focusedIndex.primary + 1 < workout.sets.count else  { return nil }
            return IntegerField.Index(primary: focusedIndex.primary + 1, secondary: 0, tertiary: focusedIndex.tertiary)
        } else if let dropSet = focusedWorkoutSet as? DropSet {
            if focusedIndex.secondary + 1 < dropSet.numberOfDrops {
                return IntegerField.Index(primary: focusedIndex.primary, secondary: focusedIndex.secondary + 1, tertiary: focusedIndex.tertiary)
            }
            guard focusedIndex.primary + 1 < workout.sets.count else { return nil }
            return IntegerField.Index(primary: focusedIndex.primary + 1, secondary: 0, tertiary: focusedIndex.tertiary)
        }
        return nil
    }
    
    internal func previousIntegerFieldIndex() -> IntegerField.Index? {
        guard let focusedIndex = focusedIntegerFieldIndex else { return nil }
        guard focusedIndex.secondary == 0 else { return IntegerField.Index(primary: focusedIndex.primary,
                                                                           secondary: focusedIndex.secondary - 1,
                                                                           tertiary: focusedIndex.tertiary) }
        guard focusedIndex.primary > 0 else { return nil }
        let previousSet = workout.sets.value(at: focusedIndex.primary - 1)
        if let _ = previousSet as? StandardSet {
            return IntegerField.Index(primary: focusedIndex.primary - 1, secondary: focusedIndex.secondary, tertiary: focusedIndex.tertiary)
        } else if let _ = previousSet as? SuperSet {
            return IntegerField.Index(primary: focusedIndex.primary - 1, secondary: 1, tertiary: focusedIndex.tertiary)
        } else if let dropSet = previousSet as? DropSet {
            return IntegerField.Index(primary: focusedIndex.primary - 1, secondary: dropSet.numberOfDrops - 1 , tertiary: focusedIndex.tertiary)
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
    
    private func playTimerSound() {
        guard let url = Bundle.main.url(forResource: "timer", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            timerSound = try AVAudioPlayer(contentsOf: url)
            timerSound?.volume = 0.25
            timerSound?.play()
        } catch {
            Logger().error("WorkoutRecorderView: Could not find and play the timer sound.")
            print()
        }
    }
    
    private var remainingChronoTimeString: String {
        "\(Int(chronograph.seconds)/60 / 10 % 6 )\(Int(chronograph.seconds)/60 % 10):\(Int(chronograph.seconds) % 60 / 10)\(Int(chronograph.seconds) % 60 % 10)"
    }
    
}

struct WorkoutRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecorderView(
            workout: Database.preview.newWorkout(),
            template: Database.preview.testTemplate
        )
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
