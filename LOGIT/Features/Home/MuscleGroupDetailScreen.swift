//
//  MuscleGroupDetailScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.26.
//

import CoreData
import SwiftUI

/// The single-muscle detail: the group's priority in the training focus, how many sets it got against
/// how many its target share asks for, a sets-history chart following the selected window, and the
/// top exercises that train it.
///
/// It used to carry a 2×2 grid of Share, Volume, Sessions and Rank. Share already sits in the hero's
/// caption and on the Muscle Groups tile that opened this page; a muscle group's kilograms is a number
/// nobody trains by; and rank is trivia. What replaced it is the one thing on this page you can act
/// on besides training: the group's priority, so the fix for a group that is always short of target
/// is on the screen that shows it. Opens scoped to the window the caller was showing — the Summary's picker carries
/// all the way down here through Muscle Groups. Pro — the full per-muscle breakdown is the analytics
/// behind the wall.
///
/// The hero counts **sets**, not share. A share is the right headline on the Muscle Groups screen,
/// where eight of them are being compared and only their relative sizes matter; on one muscle's own
/// page it is the wrong unit twice over. It reads as a progress percentage ("19%" looks like
/// something that should reach 100), and it is not actionable — nobody can train three more
/// percentage points, they train three more sets. So the target share is converted into the sets it
/// implies for this window, and the headline is the pair — beside the group's own filling track, the
/// same bar and badge the Muscle Groups screen draws, so the two screens read as one design.
///
/// The screen used to carry a calendar Week / Month / Year picker, which made it the one link in the
/// chain that changed vocabulary: Summary on four rolling weeks → Muscle Groups on four rolling
/// weeks → this screen on a calendar month, with the switch never mentioned. The route now hands
/// over a `TrendWindow` unchanged.
struct MuscleGroupDetailScreen: View {
    let muscleGroup: MuscleGroup

    @State private var window: TrendWindow

    init(muscleGroup: MuscleGroup, initialWindow: TrendWindow = .default) {
        self.muscleGroup = muscleGroup
        _window = State(initialValue: initialWindow)
    }

    @EnvironmentObject private var muscleGroupService: MuscleGroupService
    @EnvironmentObject private var focusStore: MuscleFocusStore
    @EnvironmentObject private var homeNavigationCoordinator: HomeNavigationCoordinator
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var color: Color { muscleGroup.color }

    /// The hero's height, and the track's flat fallback once accessibility sizes let the tile grow —
    /// the pair `MuscleBalanceGoalCell` uses, at hero scale. The track keeps the overview hero's
    /// proportions (its bars run about 37 wide by 130 tall).
    private static let heroHeight: CGFloat = 164
    private static let accessibilityTrackHeight: CGFloat = 104
    private static let trackWidth: CGFloat = 40
    private static let badgeDiameter: CGFloat = 22

    private var usesFixedHeight: Bool { !dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        FetchRequestWrapper(
            Workout.self,
            sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
            predicate: WorkoutPredicateFactory.getWorkouts()
        ) { allWorkouts in
            content(allWorkouts: allWorkouts)
        }
    }

    private func content(allWorkouts: [Workout]) -> some View {
        // `TrendWindow.contains` rather than a range check, so the boundary instant two windows share
        // falls on the same side here as it does in every other rolling-window surface.
        let periodWorkouts = allWorkouts.filter { ($0.date).map { window.contains($0) } ?? false }
        let occurrences = muscleGroupService.getMuscleGroupOccurances(in: periodWorkouts)
        let total = occurrences.reduce(0) { $0 + $1.1 }
        let groupSetCount = occurrences.first { $0.0 == muscleGroup }?.1 ?? 0
        let calculator = MuscleBalanceCalculator(workouts: periodWorkouts, target: focusStore.split, muscleGroupService: muscleGroupService)
        let entry = calculator.entries.first { $0.muscleGroup == muscleGroup }
            ?? MuscleBalanceEntry(muscleGroup: muscleGroup, setCount: 0, actualPercent: 0, targetPercent: focusStore.target(for: muscleGroup))

        return ScrollView {
            VStack(spacing: SECTION_SPACING) {
                TrendWindowPicker(selection: $window)
                priorityHeader
                if groupSetCount > 0 {
                    setsVsTarget(entry: entry, setCount: groupSetCount, totalSets: total)
                    setsHistoryChart(allWorkouts: allWorkouts)
                    topExercises(in: periodWorkouts)
                } else {
                    emptyState
                        .containerRelativeFrame(.vertical, alignment: .center) { height, _ in
                            max(height - 170, 300)
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
        }
        .isBlockedWithoutPro()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                // Muscle names carry their colour themselves — bold, rounded, no identity dot.
                Text(muscleGroup.description)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(color)
            }
        }
    }

    // MARK: - Priority

    private var isExcluded: Bool { focusStore.focus.isExcluded(muscleGroup) }

    /// The group's priority as the control that sets it — the same options, the same three-bar meter
    /// and the same menu shape as the focus editor's tile for this group — over the focus it belongs
    /// to. Changing it here is changing it there, including making the focus Custom.
    ///
    /// Shown whether or not the window has any sets: the priority is a setting, not a result.
    private var priorityHeader: some View {
        let focusName = focusStore.focus.matchingPreset?.title ?? NSLocalizedString("muscleFocusCustom", comment: "")
        return VStack(alignment: .leading, spacing: 0) {
            Menu {
                MusclePriorityPicker(group: muscleGroup)
            } label: {
                HStack(spacing: 7) {
                    Text(
                        isExcluded
                            ? NSLocalizedString("musclePriorityOff", comment: "")
                            : focusStore.focus.priority(for: muscleGroup).title
                    )
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.label)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.secondaryLabel)
                    MusclePriorityMeter(
                        level: isExcluded ? nil : focusStore.focus.priority(for: muscleGroup),
                        color: color
                    )
                    .padding(.leading, 4)
                }
                .padding(.vertical, 4)
                .padding(.trailing, 6)
                .contentShape(Rectangle())
            }
            // Unstretched, like the focus menu: a menu hit-tests only what its label draws.
            .accessibilityIdentifier("muscleDetailPriorityMenu")
            Text(String(format: NSLocalizedString("muscleDetailPriorityCaption", comment: ""), focusName))
                .font(.subheadline)
                .foregroundStyle(Color.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
        .animation(.snappy, value: focusStore.focus)
    }

    // MARK: - Hero

    /// Sets trained over sets the target asks for: "11/9", the app's goal shape — the weekly goal's
    /// count over its target, the Balance tile's groups over eight — in the unit the reader can
    /// actually move. Above target the numerator simply exceeds the denominator, which is what the
    /// goal screen already does for a week that beat its target.
    ///
    /// The count wears the muscle's colour, the target stays secondary, and the caption names the
    /// window and the share the target came from — the only place the percentage still appears at
    /// hero size, spelled out as a *target share* so it can't be read as progress toward 100.
    ///
    /// The standing sits under the pair as a line of text rather than a pill in the corner: it is a
    /// reading *of* those numbers, so it belongs with them. Its colour carries the verdict the way
    /// the tracks do — the muscle's colour once the group is at least at target, the same colour
    /// held back while it is short — and the word says it outright, so the state never rests on
    /// colour alone.
    ///
    /// The group's own `MuscleBalanceTrack` stands on the trailing edge, the same bar with the same
    /// badge the Muscle Groups screen draws — so the tile you tapped and the screen it opens are
    /// visibly the same object. It fills toward the *share* target while the numbers count sets;
    /// both say the same thing, since the target sets are that share applied to this window.
    private func setsVsTarget(entry: MuscleBalanceEntry, setCount: Int, totalSets: Int) -> some View {
        let targetSets = targetSetCount(targetPercent: entry.targetPercent, totalSets: totalSets)
        return HStack(alignment: .bottom, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(NSLocalizedString(isExcluded ? "sets" : "muscleDetailSetsVsTarget", comment: ""))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.label)
                    .lineLimit(1)
                Spacer(minLength: 12)
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(setCount)")
                        .foregroundStyle(color.gradient)
                    if let targetSets {
                        Text("/\(targetSets)")
                            .foregroundStyle(Color.secondaryLabel)
                    }
                }
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                if isExcluded {
                    // An excluded group has no target, and `goalState` reads a zero target as met —
                    // which would call a group the user turned off "At target", over a full badge.
                    Text(NSLocalizedString("muscleDetailNotInFocus", comment: ""))
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.secondaryLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.top, 1)
                } else {
                    standing(entry.goalState)
                        .padding(.top, 1)
                }
                Text(caption(targetPercent: entry.targetPercent))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            if !isExcluded {
                track(entry)
            }
        }
        .padding(CELL_PADDING)
        .frame(height: usesFixedHeight ? Self.heroHeight : nil)
        .tileStyle()
    }

    /// "Below target" / "At target" / "Above target" — the Muscle Groups screen's own three section
    /// titles, so the word a group is filed under there is the word it wears here.
    private func standing(_ state: MuscleBalanceGoalState) -> some View {
        let key: String
        switch state {
        // All three are the overview's section keys. The old badge read `muscleBalanceBelowTarget`,
        // `…AboveTarget` and `…OnTargetSection`, none of which has ever existed in any locale, so it
        // printed raw keys on screen.
        case .under: key = "muscleBalanceBelowTargetSection"
        case .met: key = "muscleBalanceAtTargetSection"
        case .over: key = "muscleBalanceAboveTargetSection"
        }
        return Text(NSLocalizedString(key, comment: ""))
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            // Held back while short of target, full-strength once it is met — the tracks' own rule
            // for "this one isn't there yet", in the muscle's colour rather than a warning hue.
            .foregroundStyle(state == .under ? color.opacity(0.55) : color)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    /// Fills the hero at normal sizes; at accessibility sizes the tile grows with its text, so the
    /// track takes a flat height instead — a `GeometryReader` given no height has nothing to divide.
    @ViewBuilder
    private func track(_ entry: MuscleBalanceEntry) -> some View {
        if usesFixedHeight {
            MuscleBalanceTrack(entry: entry, badgeDiameter: Self.badgeDiameter)
                .frame(width: Self.trackWidth)
                .frame(maxHeight: .infinity)
        } else {
            MuscleBalanceTrack(entry: entry, badgeDiameter: Self.badgeDiameter)
                .frame(width: Self.trackWidth, height: Self.accessibilityTrackHeight)
        }
    }

    /// The sets the target share works out to in this window. Nil when there is no honest denominator
    /// to show — a zeroed target, or a window so short that the share rounds to no sets at all — in
    /// which case the hero shows the count alone rather than inventing a "/0" to fall short of.
    private func targetSetCount(targetPercent: Int, totalSets: Int) -> Int? {
        guard targetPercent > 0, totalSets > 0 else { return nil }
        let sets = Int((Double(totalSets) * Double(targetPercent) / 100).rounded())
        return sets > 0 ? sets : nil
    }

    /// "This Month · 16% target share" — or just the window when the group has no target to speak of.
    private func caption(targetPercent: Int) -> String {
        guard targetPercent > 0 else { return periodCaption }
        return String(
            format: NSLocalizedString("muscleDetailTargetSetsCaption", comment: ""),
            periodCaption,
            targetPercent
        )
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.16))
                    .frame(width: 76, height: 76)
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(color.gradient)
            }
            VStack(spacing: 6) {
                Text(NSLocalizedString("muscleBalanceEmpty", comment: ""))
                    .font(.headline)
                Text(NSLocalizedString("muscleDetailEmptySubtitle", comment: ""))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    // MARK: - Sets history chart

    /// Sets over the selected window, one bar per day / week / month of it, scrollable back through
    /// everything logged a window at a time. Titled "Sets over time" like the overview's "Balance over
    /// time" one level up rather than "Sets per month": the bin size follows the picker, so no one
    /// unit belongs after "per".
    ///
    /// No caption beside the header. It used to say how wide the viewport was, back when that was a
    /// span the picker didn't name (twenty-eight weeks for a four-week window); the viewport is now
    /// exactly the selected window, which the picker directly above already names.
    private func setsHistoryChart(allWorkouts: [Workout]) -> some View {
        let sets = setsTraining(in: allWorkouts)
        let ranges = window.binRanges(firstDataDate: allWorkouts.compactMap(\.date).min())
        // One pass over the sets, each placed in its bin by binary search — the strip runs to hundreds
        // of bins, and filtering the whole set list per bin would be quadratic.
        var counts = [Double](repeating: 0, count: ranges.count)
        for set in sets {
            guard let date = set.workout?.date,
                  let index = TrendWindow.binIndex(of: date, in: ranges) else { continue }
            counts[index] += 1
        }
        let bins = TrendWindowBin.strip(
            for: window,
            ranges: ranges,
            raw: counts,
            display: { $0 },
            formatted: { String(Int($0.rounded())) }
        )
        return VStack(alignment: .leading, spacing: SECTION_HEADER_SPACING) {
            Text(NSLocalizedString("setsOverTime", comment: ""))
                .sectionHeaderStyle2()
                .frame(maxWidth: .infinity, alignment: .leading)
            // The shared bin chart in a compact tile — the same bars as the stat detail screens, so
            // tapping to inspect a bin and scrolling back through the history work here too, at the
            // tile's height. It keeps its own scroll position: there is no header beside it that has
            // to move with the viewport.
            TrendWindowHistoryChart(
                window: window,
                bins: bins,
                valueLabel: NSLocalizedString("sets", comment: ""),
                barStyle: AnyShapeStyle(color),
                unit: NSLocalizedString("sets", comment: ""),
                height: 120
            )
            // A fresh chart per window: the strip is re-tiled wholesale when the window changes, and
            // its scroll offset would otherwise point into a strip that no longer exists.
            .id(window)
            .padding(CELL_PADDING)
            .tileStyle()
        }
    }

    // MARK: - Top exercises

    private func topExercises(in workouts: [Workout]) -> some View {
        var byExercise: [NSManagedObjectID: (exercise: Exercise, count: Int)] = [:]
        for setGroup in setGroupsTraining(in: workouts) {
            let count = setGroup.sets.count
            if setGroup.exercise?.muscleGroup == muscleGroup, let exercise = setGroup.exercise {
                byExercise[exercise.objectID, default: (exercise, 0)].count += count
            }
            if setGroup.secondaryExercise?.muscleGroup == muscleGroup, let exercise = setGroup.secondaryExercise {
                byExercise[exercise.objectID, default: (exercise, 0)].count += count
            }
        }
        let top = byExercise.values.sorted { $0.count > $1.count }.prefix(5)
        return VStack(alignment: .leading, spacing: SECTION_HEADER_SPACING) {
            Text(NSLocalizedString("topExercises", comment: ""))
                .sectionHeaderStyle2()
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 0) {
                let items = Array(top)
                ForEach(Array(items.enumerated()), id: \.element.exercise.objectID) { index, item in
                    Button {
                        homeNavigationCoordinator.path.append(.exercise(item.exercise))
                    } label: {
                        HStack(spacing: 12) {
                            // Circular, like every other glyph slot in the muscle screens since the
                            // overview's section headers moved off rounded squares.
                            Image(systemName: "dumbbell.fill")
                                .font(.subheadline)
                                .foregroundStyle(color.gradient)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Color.fill))
                            Text(item.exercise.displayName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.label)
                                .lineLimit(1)
                            Spacer()
                            UnitView(value: "\(item.count)", unit: NSLocalizedString("sets", comment: ""), unitColor: .secondaryLabel)
                                .foregroundStyle(.secondary)
                            NavigationChevron()
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if index < items.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, CELL_PADDING)
            .tileStyle()
            .emptyPlaceholder(Array(top)) {
                Text(NSLocalizedString("noData", comment: ""))
            }
        }
    }

    // MARK: - Helpers

    private var periodCaption: String {
        window.currentWindowLabel
    }

    private func setGroupsTraining(in workouts: [Workout]) -> [WorkoutSetGroup] {
        workouts.flatMap { $0.setGroups }.filter {
            $0.exercise?.muscleGroup == muscleGroup || $0.secondaryExercise?.muscleGroup == muscleGroup
        }
    }

    private func setsTraining(in workouts: [Workout]) -> [WorkoutSet] {
        setGroupsTraining(in: workouts).flatMap { $0.sets }
    }
}
