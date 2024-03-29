//
//  WorkoutRecorderScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import AVFoundation
import CoreData
import OSLog
import SwiftUI
import UIKit

struct WorkoutRecorderScreen: View {

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
    @State internal var workoutSetTemplateSetDictionary = [WorkoutSet: TemplateSet]()

    @StateObject var chronograph = Chronograph()
    @State internal var isShowingChronoView = false
    @State private var shouldShowChronoViewAgainWhenPossible = false
    @State private var isShowingChronoInHeader = false
    @State private var shouldFlash = false
    @State private var didAppear = false
    @State private var timerSound: AVAudioPlayer?

    @State private var isShowingFinishConfirmation = false
    @State internal var sheetType: WorkoutSetGroupList.SheetType?

    @State internal var focusedIntegerFieldIndex: IntegerField.Index?

    @FocusState internal var isFocusingTitleTextfield: Bool

    // MARK: - Variables

    let template: Template?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { scrollable in
                    ScrollView {
                        WorkoutSetGroupList(
                            workout: workout,
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                            sheetType: $sheetType,
                            canReorder: true
                        )
                        .padding(.horizontal)
                        .padding(.top, 90)
                        .environment(
                            \.workoutSetTemplateSetDictionary,
                            workoutSetTemplateSetDictionary
                        )
                        .environment(\.setWorkoutEndDate, { workout.endDate = $0 })

                        Button {
                            sheetType = .exerciseSelection(
                                exercise: nil,
                                setExercise: { exercise in
                                    database.newWorkoutSetGroup(
                                        createFirstSetAutomatically: true,
                                        exercise: exercise,
                                        workout: workout
                                    )
                                    database.refreshObjects()
                                    withAnimation {
                                        scrollable.scrollTo(1, anchor: .bottom)
                                    }
                                },
                                forSecondary: false
                            )
                        } label: {
                            Label(
                                NSLocalizedString("addExercise", comment: ""),
                                systemImage: "plus.circle.fill"
                            )
                        }
                        .buttonStyle(BigButtonStyle())
                        .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
                        .padding(.horizontal)
                        .padding(.vertical, 30)
                        .id(1)
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
            .toolbar {
                ToolbarItemsBottomBar
                ToolbarItemsKeyboard
            }
            .fullScreenCover(item: $sheetType) { type in
                NavigationStack {
                    switch type {
                    case let .exerciseDetail(exercise):
                        ExerciseDetailScreen(exercise: exercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("dismiss", comment: "")) {
                                        sheetType = nil
                                    }
                                }
                            }
                            .tag("detail")
                    case let .exerciseSelection(exercise, setExercise, forSecondary):
                        ExerciseSelectionScreen(
                            selectedExercise: exercise,
                            setExercise: setExercise,
                            forSecondary: forSecondary
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                                    sheetType = nil
                                }
                            }
                        }
                        .tag("selection")
                    }
                }
            }
            .confirmationDialog(
                Text(
                    workout.allSetsHaveEntries
                        ? NSLocalizedString("finishWorkoutConfimation", comment: "")
                        : !workout.hasEntries
                            ? NSLocalizedString("noEntriesConfirmation", comment: "")
                            : NSLocalizedString("deleteSetsWithoutEntries", comment: "")
                ),
                isPresented: $isShowingFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button(
                    workout.allSetsHaveEntries
                        ? NSLocalizedString("finishWorkout", comment: "")
                        : !workout.hasEntries
                            ? NSLocalizedString("noEntriesConfirmation", comment: "")
                            : NSLocalizedString("deleteSets", comment: "")
                ) {
                    workout.sets.filter({ !$0.hasEntry }).forEach { database.delete($0) }
                    if workout.isEmpty {
                        database.delete(workout, saveContext: true)
                    } else {
                        saveWorkout()
                    }
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
                shouldShowChronoViewAgainWhenPossible =
                    shouldShowChronoViewAgainWhenPossible
                    ? shouldShowChronoViewAgainWhenPossible : isShowingChronoView
                isShowingChronoView = false
            }
            withAnimation {
                isShowingChronoInHeader = chronograph.status != .idle && newValue != nil
            }
        }
        .onAppear {
            // onAppear called twice because of bug
            if !didAppear {
                didAppear = true
                chronograph.onTimerFired = {
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
                        Divider()
                            .frame(height: 20)
                        TimeStringView
                    }
                }
                HStack {
                    TextField(
                        Workout.getStandardName(for: Date()),
                        text: workoutName,
                        axis: .vertical
                    )
                    .focused($isFocusingTitleTextfield)
                    .lineLimit(2)
                    .foregroundColor(.label)
                    .font(.title2.weight(.bold))
                    Spacer()
                    ProgressCircleButton(
                        progress: workout.setGroups.count > 0 ? progressInWorkout : 0.0
                    ) {
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
        HStack {
            Image(systemName: chronograph.mode == .timer ? "timer" : "stopwatch")
            Text(remainingChronoTimeString)
        }
        .foregroundColor(chronograph.status == .running ? .accentColor : .secondaryLabel)
        .font(.body.weight(.semibold).monospacedDigit())
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
            let focusedWorkoutSet = workout.sets.value(at: focusedIndex.primary)
        else { return nil }
        if let _ = focusedWorkoutSet as? StandardSet {
            guard focusedIndex.primary + 1 < workout.sets.count else { return nil }
            return IntegerField.Index(
                primary: focusedIndex.primary + 1,
                secondary: 0,
                tertiary: focusedIndex.tertiary
            )
        } else if let _ = focusedWorkoutSet as? SuperSet {
            guard focusedIndex.secondary == 1 else {
                return IntegerField.Index(
                    primary: focusedIndex.primary,
                    secondary: 1,
                    tertiary: focusedIndex.tertiary
                )
            }
            guard focusedIndex.primary + 1 < workout.sets.count else { return nil }
            return IntegerField.Index(
                primary: focusedIndex.primary + 1,
                secondary: 0,
                tertiary: focusedIndex.tertiary
            )
        } else if let dropSet = focusedWorkoutSet as? DropSet {
            if focusedIndex.secondary + 1 < dropSet.numberOfDrops {
                return IntegerField.Index(
                    primary: focusedIndex.primary,
                    secondary: focusedIndex.secondary + 1,
                    tertiary: focusedIndex.tertiary
                )
            }
            guard focusedIndex.primary + 1 < workout.sets.count else { return nil }
            return IntegerField.Index(
                primary: focusedIndex.primary + 1,
                secondary: 0,
                tertiary: focusedIndex.tertiary
            )
        }
        return nil
    }

    internal func previousIntegerFieldIndex() -> IntegerField.Index? {
        guard let focusedIndex = focusedIntegerFieldIndex else { return nil }
        guard focusedIndex.secondary == 0 else {
            return IntegerField.Index(
                primary: focusedIndex.primary,
                secondary: focusedIndex.secondary - 1,
                tertiary: focusedIndex.tertiary
            )
        }
        guard focusedIndex.primary > 0 else { return nil }
        let previousSet = workout.sets.value(at: focusedIndex.primary - 1)
        if let _ = previousSet as? StandardSet {
            return IntegerField.Index(
                primary: focusedIndex.primary - 1,
                secondary: focusedIndex.secondary,
                tertiary: focusedIndex.tertiary
            )
        } else if let _ = previousSet as? SuperSet {
            return IntegerField.Index(
                primary: focusedIndex.primary - 1,
                secondary: 1,
                tertiary: focusedIndex.tertiary
            )
        } else if let dropSet = previousSet as? DropSet {
            return IntegerField.Index(
                primary: focusedIndex.primary - 1,
                secondary: dropSet.numberOfDrops - 1,
                tertiary: focusedIndex.tertiary
            )
        }
        return nil
    }

    private func updateWorkout(with template: Template) {
        template.workouts.append(workout)
        workout.name = template.name
        for templateSetGroup in template.setGroups {
            let setGroup = database.newWorkoutSetGroup(
                createFirstSetAutomatically: false,
                exercise: templateSetGroup.exercise,
                workout: workout
            )
            templateSetGroup.sets
                .forEach { templateSet in
                    if let templateStandardSet = templateSet as? TemplateStandardSet {
                        let standardSet = database.newStandardSet(setGroup: setGroup)
                        workoutSetTemplateSetDictionary[standardSet] = templateStandardSet
                    } else if let templateDropSet = templateSet as? TemplateDropSet {
                        let dropSet = database.newDropSet(from: templateDropSet, setGroup: setGroup)
                        workoutSetTemplateSetDictionary[dropSet] = templateDropSet
                    } else if let templateSuperSet = templateSet as? TemplateSuperSet {
                        let superSet = database.newSuperSet(
                            from: templateSuperSet,
                            setGroup: setGroup
                        )
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
        
        workout.exercises.forEach { database.unflagAsTemporary($0) }
        database.deleteAllTemporaryObjects()
        database.refreshObjects()
        
        database.save()
    }

    private func deleteWorkout() {
        database.deleteAllTemporaryObjects()
        database.refreshObjects()

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
            Logger().error("WorkoutRecorderScreen: Could not find and play the timer sound.")
        }
    }

    private var remainingChronoTimeString: String {
        "\(Int(chronograph.seconds)/60 / 10 % 6 )\(Int(chronograph.seconds)/60 % 10):\(Int(chronograph.seconds) % 60 / 10)\(Int(chronograph.seconds) % 60 % 10)"
    }

}

private struct PreviewWrapperView: View {
    @EnvironmentObject private var database: Database
    
    var body: some View {
        WorkoutRecorderScreen(
            workout: database.newWorkout(),
            template: database.testTemplate
        )
    }
}

struct WorkoutRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .previewEnvironmentObjects()
    }
}
