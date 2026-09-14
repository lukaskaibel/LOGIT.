//
//  WorkoutLiveActivityAttributes.swift
//  LOGIT
//
//  Created by Codex on 28.03.26.
//

import ActivityKit
import Foundation

enum WorkoutLiveActivityChronoPhase: String, Codable, Hashable {
    case timerRunning
    case timerPaused
    case stopwatchRunning
    case stopwatchPaused
}

/// Drives chrono tinting to mirror `WorkoutRecorderFloatingTimerButton`: the resting set's muscle colour for
/// auto rest (timer or stopwatch), the app accent for a manually started timer or stopwatch.
enum WorkoutLiveActivityChronoTintKind: String, Codable, Hashable {
    case restTimer
    case restStopwatch
    case manual
}

struct WorkoutLiveActivityChronoChip: Codable, Hashable {
    let phase: WorkoutLiveActivityChronoPhase
    let tintKind: WorkoutLiveActivityChronoTintKind
    /// Set for `.restTimer` and `.restStopwatch` (muscle group of the set that triggered rest).
    let muscleThemeToken: WorkoutLiveActivityThemeToken?
    let timerEndDate: Date?
    /// The timer's full duration — for a running timer and a paused one, so both can draw progress.
    let timerTotalSeconds: Double?
    let staticTickSeconds: Int?
    let stopwatchStartDate: Date?

    private static let dateEqualityTolerance: TimeInterval = 1.5

    private static func datesEqual(_ a: Date?, _ b: Date?) -> Bool {
        switch (a, b) {
        case let (a?, b?):
            return abs(a.timeIntervalSince(b)) < dateEqualityTolerance
        case (nil, nil):
            return true
        default:
            return false
        }
    }

    private static func roundedEpoch(_ date: Date?) -> Int? {
        guard let date else { return nil }
        return Int(date.timeIntervalSinceReferenceDate.rounded())
    }

    static func == (lhs: WorkoutLiveActivityChronoChip, rhs: WorkoutLiveActivityChronoChip) -> Bool {
        lhs.phase == rhs.phase
            && lhs.tintKind == rhs.tintKind
            && lhs.muscleThemeToken == rhs.muscleThemeToken
            && datesEqual(lhs.timerEndDate, rhs.timerEndDate)
            && lhs.timerTotalSeconds == rhs.timerTotalSeconds
            && lhs.staticTickSeconds == rhs.staticTickSeconds
            && datesEqual(lhs.stopwatchStartDate, rhs.stopwatchStartDate)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(phase)
        hasher.combine(tintKind)
        hasher.combine(muscleThemeToken)
        hasher.combine(Self.roundedEpoch(timerEndDate))
        hasher.combine(timerTotalSeconds)
        hasher.combine(staticTickSeconds)
        hasher.combine(Self.roundedEpoch(stopwatchStartDate))
    }
}

struct WorkoutLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Heading only while the workout has no exercise yet; otherwise the exercise leads.
        let workoutTitle: String
        let exerciseIndex: Int
        let exerciseCount: Int
        let setIndex: Int
        let setCount: Int
        /// For supersets, the **focused** exercise (first until `repetitionsFirstExercise > 0`, then the second).
        let primaryExerciseName: String
        /// Superset **partner** exercise, shown on the identity line after the turn arrow; `nil` when not a superset.
        let secondaryExerciseName: String?
        /// `true` when the partner was performed before the focused exercise within this set.
        /// Optional for decoding older payloads that omit this key (`nil` treated as `false`).
        let supersetPartnerIsLeading: Bool?
        let primaryMetrics: ExerciseMetricDisplay
        let themeToken: WorkoutLiveActivityThemeToken
        let chronoChip: WorkoutLiveActivityChronoChip?
        /// `false` once every set of the workout is logged, so the rest card has nothing to announce
        /// as next. Optional for older payloads (`nil` treated as `true`).
        let hasPendingSet: Bool?

        /// Current set index within the active set group (e.g. `2/4`). Nil when there is no set group.
        var setFractionLabel: String? {
            guard setCount > 0 else { return nil }
            return "\(max(setIndex, 0))/\(max(setCount, 0))"
        }
    }

    let workoutID: UUID
    let startedAt: Date
}

/// Segmented reps/weight for Live Activity, mirroring `IntegerField` / `DecimalField` in `WorkoutSetCell`
/// (placeholder gray when the stored value is still 0; filled white + secondary unit when entered).
struct ExerciseMetricDisplay: Codable, Hashable {
    let repetitionSegments: [String]
    let repetitionSegmentPlaceholders: [Bool]
    let repetitionsUnit: String
    let weightSegments: [String]
    let weightSegmentPlaceholders: [Bool]
    let weightUnit: String

    var isEmpty: Bool {
        repetitionSegments.isEmpty && weightSegments.isEmpty
    }

    /// First weight value for compact Dynamic Island leading (includes placeholder flag for `WorkoutSetCell`-style tint).
    var compactWeightValueUnitAndPlaceholder: (value: String, unit: String, isPlaceholder: Bool)? {
        guard let value = weightSegments.first else { return nil }
        let isPlaceholder = weightSegmentPlaceholders.first ?? false
        return (value, weightUnit, isPlaceholder)
    }

    static func emptyForLiveActivity() -> ExerciseMetricDisplay {
        let weightUnitRaw = UserDefaults.standard.string(forKey: "weightUnit") ?? "kg"
        return ExerciseMetricDisplay(
            repetitionSegments: [],
            repetitionSegmentPlaceholders: [],
            repetitionsUnit: NSLocalizedString("reps", comment: ""),
            weightSegments: [],
            weightSegmentPlaceholders: [],
            weightUnit: weightUnitRaw
        )
    }
}

enum WorkoutLiveActivityThemeToken: String, Codable, Hashable {
    case chest
    case triceps
    case shoulders
    case biceps
    case back
    case legs
    case abdominals
    case cardio
    case neutral
}

#if DEBUG
/// Deterministic Live Activity states, shared by the widget's `#Preview`s and the
/// `-UITEST_LIVE_ACTIVITY <fixture>` launch hook — which starts the activity with exactly this state
/// instead of mirroring the recorder, so every presentation can be captured from a UI test
/// (`LOGITUITests/LiveActivityScreenshots.swift`) without driving a real workout.
enum WorkoutLiveActivityFixture: String, CaseIterable {
    case templateSet
    case weightEntered
    case superset
    case dropSetLongName
    case emptyWorkout
    case restTimer
    case restTimerPaused
    case restStopwatch
    case lastSetRest
    case manualTimer
    case manualStopwatch

    static var launchFixture: WorkoutLiveActivityFixture? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-UITEST_LIVE_ACTIVITY"), index + 1 < args.count else {
            return nil
        }
        return WorkoutLiveActivityFixture(rawValue: args[index + 1])
    }

    /// The activity this fixture starts, timers anchored to `now`.
    func activity(
        now: Date = .now
    ) -> (attributes: WorkoutLiveActivityAttributes, state: WorkoutLiveActivityAttributes.ContentState) {
        let attributes = WorkoutLiveActivityAttributes(
            workoutID: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            startedAt: now.addingTimeInterval(-(23 * 60 + 41))
        )
        return (attributes, state(now: now))
    }

    func state(now: Date = .now) -> WorkoutLiveActivityAttributes.ContentState {
        switch self {
        case .templateSet:
            return Self.inclineBench(metrics: Self.metrics(reps: ("8", true), weight: ("60", true)))
        case .weightEntered:
            return Self.inclineBench(metrics: Self.metrics(reps: ("8", true), weight: ("62.5", false)))
        case .superset:
            return WorkoutLiveActivityAttributes.ContentState(
                workoutTitle: "Arms",
                exerciseIndex: 4,
                exerciseCount: 6,
                setIndex: 2,
                setCount: 3,
                primaryExerciseName: "Rope Pushdowns",
                secondaryExerciseName: "Cable Curls",
                supersetPartnerIsLeading: true,
                primaryMetrics: Self.metrics(reps: ("15", true), weight: ("27.5", true)),
                themeToken: .triceps,
                chronoChip: nil,
                hasPendingSet: true
            )
        case .dropSetLongName:
            return WorkoutLiveActivityAttributes.ContentState(
                workoutTitle: "Shoulders",
                exerciseIndex: 5,
                exerciseCount: 7,
                setIndex: 3,
                setCount: 3,
                primaryExerciseName: "Single-Arm Cable Lateral Raise",
                secondaryExerciseName: nil,
                supersetPartnerIsLeading: false,
                primaryMetrics: ExerciseMetricDisplay(
                    repetitionSegments: ["12", "10", "8"],
                    repetitionSegmentPlaceholders: [false, true, true],
                    repetitionsUnit: NSLocalizedString("reps", comment: ""),
                    weightSegments: ["12.5", "10", "7.5"],
                    weightSegmentPlaceholders: [false, false, true],
                    weightUnit: "kg"
                ),
                themeToken: .shoulders,
                chronoChip: nil,
                hasPendingSet: true
            )
        case .emptyWorkout:
            return WorkoutLiveActivityAttributes.ContentState(
                workoutTitle: "Upper Body",
                exerciseIndex: 0,
                exerciseCount: 0,
                setIndex: 0,
                setCount: 0,
                primaryExerciseName: NSLocalizedString("addExercise", comment: ""),
                secondaryExerciseName: nil,
                supersetPartnerIsLeading: false,
                primaryMetrics: .emptyForLiveActivity(),
                themeToken: .neutral,
                chronoChip: nil,
                hasPendingSet: false
            )
        case .restTimer, .lastSetRest:
            return Self.inclineBench(
                metrics: Self.metrics(reps: ("8", true), weight: ("60", true)),
                chronoChip: WorkoutLiveActivityChronoChip(
                    phase: .timerRunning,
                    tintKind: .restTimer,
                    muscleThemeToken: .chest,
                    timerEndDate: now.addingTimeInterval(97),
                    timerTotalSeconds: 150,
                    staticTickSeconds: nil,
                    stopwatchStartDate: nil
                ),
                hasPendingSet: self == .restTimer
            )
        case .restTimerPaused:
            return Self.inclineBench(
                metrics: Self.metrics(reps: ("8", true), weight: ("60", true)),
                chronoChip: WorkoutLiveActivityChronoChip(
                    phase: .timerPaused,
                    tintKind: .restTimer,
                    muscleThemeToken: .chest,
                    timerEndDate: nil,
                    timerTotalSeconds: 150,
                    staticTickSeconds: 97,
                    stopwatchStartDate: nil
                )
            )
        case .restStopwatch:
            return Self.hackSquat(
                chronoChip: WorkoutLiveActivityChronoChip(
                    phase: .stopwatchRunning,
                    tintKind: .restStopwatch,
                    muscleThemeToken: .legs,
                    timerEndDate: nil,
                    timerTotalSeconds: nil,
                    staticTickSeconds: nil,
                    stopwatchStartDate: now.addingTimeInterval(-83)
                )
            )
        case .manualStopwatch:
            return Self.hackSquat(
                chronoChip: WorkoutLiveActivityChronoChip(
                    phase: .stopwatchRunning,
                    tintKind: .manual,
                    muscleThemeToken: nil,
                    timerEndDate: nil,
                    timerTotalSeconds: nil,
                    staticTickSeconds: nil,
                    stopwatchStartDate: now.addingTimeInterval(-83)
                )
            )
        case .manualTimer:
            return WorkoutLiveActivityAttributes.ContentState(
                workoutTitle: "Core",
                exerciseIndex: 2,
                exerciseCount: 4,
                setIndex: 2,
                setCount: 3,
                primaryExerciseName: "Plank",
                secondaryExerciseName: nil,
                supersetPartnerIsLeading: false,
                primaryMetrics: ExerciseMetricDisplay(
                    repetitionSegments: ["1:00"],
                    repetitionSegmentPlaceholders: [true],
                    repetitionsUnit: "",
                    weightSegments: [],
                    weightSegmentPlaceholders: [],
                    weightUnit: "kg"
                ),
                themeToken: .abdominals,
                chronoChip: WorkoutLiveActivityChronoChip(
                    phase: .timerRunning,
                    tintKind: .manual,
                    muscleThemeToken: nil,
                    timerEndDate: now.addingTimeInterval(42),
                    timerTotalSeconds: 60,
                    staticTickSeconds: nil,
                    stopwatchStartDate: nil
                ),
                hasPendingSet: true
            )
        }
    }

    private static func inclineBench(
        metrics: ExerciseMetricDisplay,
        chronoChip: WorkoutLiveActivityChronoChip? = nil,
        hasPendingSet: Bool = true
    ) -> WorkoutLiveActivityAttributes.ContentState {
        WorkoutLiveActivityAttributes.ContentState(
            workoutTitle: "Push Day",
            exerciseIndex: 2,
            exerciseCount: 3,
            setIndex: 4,
            setCount: 4,
            primaryExerciseName: "Incline Bench Press",
            secondaryExerciseName: nil,
            supersetPartnerIsLeading: false,
            primaryMetrics: metrics,
            themeToken: .chest,
            chronoChip: chronoChip,
            hasPendingSet: hasPendingSet
        )
    }

    private static func hackSquat(chronoChip: WorkoutLiveActivityChronoChip) -> WorkoutLiveActivityAttributes.ContentState {
        WorkoutLiveActivityAttributes.ContentState(
            workoutTitle: "Leg Day",
            exerciseIndex: 3,
            exerciseCount: 5,
            setIndex: 3,
            setCount: 4,
            primaryExerciseName: "Hack Squat",
            secondaryExerciseName: nil,
            supersetPartnerIsLeading: false,
            primaryMetrics: metrics(reps: ("12", true), weight: ("140", true)),
            themeToken: .legs,
            chronoChip: chronoChip,
            hasPendingSet: true
        )
    }

    private static func metrics(
        reps: (value: String, isPlaceholder: Bool),
        weight: (value: String, isPlaceholder: Bool)
    ) -> ExerciseMetricDisplay {
        ExerciseMetricDisplay(
            repetitionSegments: [reps.value],
            repetitionSegmentPlaceholders: [reps.isPlaceholder],
            repetitionsUnit: NSLocalizedString("reps", comment: ""),
            weightSegments: [weight.value],
            weightSegmentPlaceholders: [weight.isPlaceholder],
            weightUnit: "kg"
        )
    }
}
#endif
