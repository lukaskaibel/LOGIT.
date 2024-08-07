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
    @Environment(\.fullScreenDraggableCoverTopInset) var fullScreenDraggableCoverTopInset

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @EnvironmentObject var database: Database
    @EnvironmentObject var workoutRecorder: WorkoutRecorder

    // MARK: - State

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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                if let workout = workoutRecorder.workout {
                    ScrollViewReader { scrollable in
                        ScrollView {
                            VStack {
                                WorkoutSetGroupList(
                                    workout: workout,
                                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex,
                                    sheetType: $sheetType,
                                    canReorder: true
                                )
                                .padding(.horizontal)
                                .padding(.top, 90)
                                .padding(.top, fullScreenDraggableCoverTopInset)

                                Button {
                                    sheetType = .exerciseSelection(
                                        exercise: nil,
                                        setExercise: { exercise in
                                            workoutRecorder.addSetGroup(with: exercise)
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
                        }
                        .scrollIndicators(.hidden)
                    }
                }

                Header
                    .fullScreenDraggableCoverDragArea()
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
                    workoutRecorder.workout?.allSetsHaveEntries ?? false
                        ? NSLocalizedString("finishWorkoutConfimation", comment: "")
                        : !(workoutRecorder.workout?.hasEntries ?? false)
                            ? NSLocalizedString("noEntriesConfirmation", comment: "")
                            : NSLocalizedString("deleteSetsWithoutEntries", comment: "")
                ),
                isPresented: $isShowingFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button(
                    workoutRecorder.workout?.allSetsHaveEntries ?? false
                        ? NSLocalizedString("finishWorkout", comment: "")
                        : !(workoutRecorder.workout?.hasEntries ?? false)
                            ? NSLocalizedString("noEntriesConfirmation", comment: "")
                            : NSLocalizedString("deleteSets", comment: "")
                ) {
                    workoutRecorder.saveWorkout()
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
                Rectangle()
                    .frame(width: 40, height: 5)
                    .clipShape(Capsule())
                HStack {
                    if let workoutStartTime = workoutRecorder.workout?.date {
                        StopwatchView(startTime: workoutStartTime)
                            .font(.body.weight(.bold).monospacedDigit())
                    }
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
                        progress: progressInWorkout
                    ) {
                        if !(workoutRecorder.workout?.hasEntries ?? false) {
                            workoutRecorder.saveWorkout()
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
            .fullScreenDraggableCoverTopInset()
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
        Binding(get: { workoutRecorder.workout?.name ?? "" }, set: { workoutRecorder.workout?.name = $0 })
    }

    private var progressInWorkout: Float {
        guard let workout = workoutRecorder.workout, workout.setGroups.count > 0 else { return 0 }
        return Float((workout.sets.filter { $0.hasEntry }).count) / Float(workout.sets.count)
    }

    internal func indexInSetGroup(for workoutSet: WorkoutSet) -> Int? {
        guard let workout = workoutRecorder.workout else { return nil }
        for setGroup in workout.setGroups {
            if let index = setGroup.index(of: workoutSet) {
                return index
            }
        }
        return nil
    }

    internal var selectedWorkoutSet: WorkoutSet? {
        guard let focusedIndex = focusedIntegerFieldIndex else { return nil }
        return workoutRecorder.workout?.sets.value(at: focusedIndex.primary)
    }

    internal func nextIntegerFieldIndex() -> IntegerField.Index? {
        guard let workout = workoutRecorder.workout else { return nil }
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
        guard let workout = workoutRecorder.workout else { return nil }
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
    @EnvironmentObject private var workoutRecorder: WorkoutRecorder
    
    var body: some View {
        WorkoutRecorderScreen()
            .onAppear {
                workoutRecorder.startWorkout(from: database.testTemplate)
            }
    }
}

struct WorkoutRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .previewEnvironmentObjects()
    }
}
