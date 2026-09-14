//
//  MuscleBalanceCalculator.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.26.
//

import Foundation

/// Where a muscle group sits against its target: it counts as soon as it is **at least** its target.
/// Deliberately not symmetric — every surface draws a track filling toward a target, and a bar that is
/// visibly full while the verdict says "not there yet" is a tile arguing with itself. Overshoot still
/// counts; it just says so.
///
/// The one verdict in the app, read by the Summary tile, the Muscle Groups screen and the muscle
/// detail alike.
enum MuscleBalanceGoalState {
    /// Short of target — the track is partly filled and the remainder shows.
    case under
    /// Exactly at target.
    case met
    /// Past target, by even one set: met, but worth admitting. Targets are whole sets per week, so
    /// "one more than you planned" is already a real difference rather than rounding noise.
    case over
}

/// One muscle group's standing against its weekly set target for a given window: how many sets
/// trained it, what that works out to per week, and the target it is read against. The filling
/// `MuscleBalanceTrack` (Summary tile, overview hero and tiles, single-muscle detail) renders off these.
struct MuscleBalanceEntry: Identifiable {
    let muscleGroup: MuscleGroup
    /// Set occurrences training this group in the window (a super set counts toward both its groups,
    /// matching `MuscleGroupService`).
    let setCount: Int
    /// `setCount` as a weekly average, rounded to whole sets — the number every surface shows, and
    /// the one the verdict is decided on, so "10/10" can never read "below target".
    let setsPerWeek: Int
    /// The user's weekly set target for this group; 0 when it isn't part of the focus.
    let target: Int

    var id: MuscleGroup { muscleGroup }

    /// How full this group's track is, 1 meaning "at target". Nil when the group has no target: a
    /// track that can never fill isn't a goal, and shouldn't be drawn or counted.
    var goalFraction: Double? {
        guard target > 0 else { return nil }
        return Double(setsPerWeek) / Double(target)
    }

    /// The goal reading — see `MuscleBalanceGoalState`.
    var goalState: MuscleBalanceGoalState {
        guard target > 0 else { return .met }
        if setsPerWeek < target { return .under }
        return setsPerWeek > target ? .over : .met
    }
}

/// Turns a window's workouts + the user's focus into per-group balance entries. Window-agnostic: the
/// caller supplies the workouts already narrowed to the window and how many weeks it covers (see
/// `TrendWindow.weeksCovered`).
struct MuscleBalanceCalculator {
    /// One entry per muscle group, in `MuscleGroup.allCases` order (zero-filled for untrained groups).
    let entries: [MuscleBalanceEntry]
    /// Total set occurrences across all groups in the window.
    let totalSets: Int

    init(
        workouts: [Workout],
        focus: MuscleFocus,
        weeks: Double,
        muscleGroupService: MuscleGroupService = MuscleGroupService()
    ) {
        let counts: [MuscleGroup: Int] = muscleGroupService
            .getMuscleGroupOccurances(in: workouts)
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        let divisor = max(weeks, 1)
        entries = MuscleGroup.allCases.map { group in
            let count = counts[group] ?? 0
            return MuscleBalanceEntry(
                muscleGroup: group,
                setCount: count,
                setsPerWeek: Int((Double(count) / divisor).rounded()),
                target: focus.target(for: group)
            )
        }
        totalSets = counts.values.reduce(0, +)
    }

    // MARK: - Aggregates

    /// The groups the goal reading applies to: those with a target. A group set to 0 is an explicit
    /// "I don't train this", so it leaves the chart and the denominator rather than sitting as a track
    /// that can never fill.
    var goalEntries: [MuscleBalanceEntry] {
        entries.filter { $0.target > 0 }
    }

    /// Numerator for the Balance tile: groups at least at their target.
    func atLeastTargetCount() -> Int {
        goalEntries.filter { $0.goalState != .under }.count
    }
}

// MARK: - Weekly sets history

/// The muscle detail's history, in the page's own unit: sets per week, one bar per rolling week of the
/// selected window — 4 for four weeks, 13 for three months — and, for a year, one bar per calendar month
/// showing that month's average sets per week, because 52 week bars are too thin to read in a tile.
///
/// Weeks roll back from now, like `TrendWindow` itself, so four weekly bars tile exactly the window the
/// hero's weekly average is taken over, and the newest bar is a whole week rather than a part-elapsed
/// calendar one that would read misleadingly short. Months can be calendar months, which label exactly
/// ("Sep" is September): a month bar is an average, and the current month's is taken over its days so
/// far, so being part-elapsed doesn't shorten it.
///
/// Sets are counted the way `MuscleGroupService` counts them for the hero — once per set for its
/// exercise's group and once more for a superset partner's.
enum MuscleWeeklySets {
    struct Bin: Identifiable, Equatable {
        /// Half-open at the lower edge, like every rolling range in the app.
        let range: ClosedRange<Date>
        /// Sets in the range, averaged per week over the part of it that has history, rounded.
        let setsPerWeek: Int

        var id: Date { range.upperBound }
    }

    /// The bars' ranges for `window`, oldest first, the newest ending at `now`. Week boundaries are
    /// each stepped back from `now` directly; month boundaries are calendar month starts, the newest
    /// running from the current month's first instant to `now`.
    static func ranges(for window: TrendWindow, now: Date = .now, calendar: Calendar = .current) -> [ClosedRange<Date>] {
        switch window {
        case .fourWeeks, .threeMonths:
            let count = window == .fourWeeks ? 4 : 13
            func boundary(_ weeksBack: Int) -> Date {
                calendar.date(byAdding: .day, value: -7 * weeksBack, to: now) ?? now
            }
            return (0 ..< count).reversed().map { boundary($0 + 1) ... boundary($0) }
        case .oneYear:
            guard let currentMonth = calendar.dateInterval(of: .month, for: now) else { return [] }
            var ranges = [currentMonth.start ... now]
            var cursor = currentMonth.start
            for _ in 0 ..< 11 {
                guard let previous = calendar.date(byAdding: .month, value: -1, to: cursor) else { break }
                ranges.append(previous ... cursor)
                cursor = previous
            }
            return ranges.reversed()
        }
    }

    /// Drops the bars that end before the first workout: weeks nobody could have trained aren't missed
    /// targets, and a year of history-less gaps would push the real bars into a corner. Always keeps
    /// the newest bar.
    static func trimmed(_ ranges: [ClosedRange<Date>], firstDataDate: Date?) -> [ClosedRange<Date>] {
        guard let firstDataDate else { return ranges }
        let kept = ranges.filter { $0.upperBound > firstDataDate }
        return kept.isEmpty ? Array(ranges.suffix(1)) : kept
    }

    /// A bar's value: `count` sets averaged per week over the part of `range` that has history, never
    /// dividing by less than a week — so a week bar is simply its set count, and a month bar is its
    /// weekly average without a first, part-trained month reading low.
    static func setsPerWeek(count: Int, in range: ClosedRange<Date>, firstDataDate: Date?, now: Date = .now) -> Int {
        let week: TimeInterval = 7 * 24 * 60 * 60
        let start = max(range.lowerBound, firstDataDate ?? range.lowerBound)
        let end = min(range.upperBound, now)
        let weeks = max(end.timeIntervalSince(start) / week, 1)
        return Int((Double(count) / weeks).rounded())
    }

    /// The bars for `muscleGroup` over `window`, from every logged workout.
    static func bins(
        window: TrendWindow,
        workouts: [Workout],
        muscleGroup: MuscleGroup,
        now: Date = .now
    ) -> [Bin] {
        let firstDataDate = workouts.compactMap(\.date).min()
        let ranges = trimmed(ranges(for: window, now: now), firstDataDate: firstDataDate)
        var counts = [Int](repeating: 0, count: ranges.count)
        for workout in workouts {
            guard let date = workout.date, let index = TrendWindow.binIndex(of: date, in: ranges) else { continue }
            for set in workout.sets {
                if set.setGroup?.exercise?.muscleGroup == muscleGroup { counts[index] += 1 }
                if set.setGroup?.secondaryExercise?.muscleGroup == muscleGroup { counts[index] += 1 }
            }
        }
        return zip(ranges, counts).map { range, count in
            Bin(range: range, setsPerWeek: setsPerWeek(count: count, in: range, firstDataDate: firstDataDate, now: now))
        }
    }

    /// The label under a bar: a week's first day ("Aug 16"), or a month's name ("Sep").
    static func label(for range: ClosedRange<Date>, window: TrendWindow) -> String {
        switch window {
        case .fourWeeks, .threeMonths:
            return range.lowerBound.formatted(.dateTime.day().month(.abbreviated))
        case .oneYear:
            return range.lowerBound.formatted(.dateTime.month(.abbreviated))
        }
    }
}
