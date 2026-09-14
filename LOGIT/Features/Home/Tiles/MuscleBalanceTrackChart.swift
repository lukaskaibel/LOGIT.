//
//  MuscleBalanceTrackChart.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 28.07.26.
//

import SwiftUI

/// One filling track per muscle group, each normalised to **its own** target.
///
/// That normalisation is the whole design. Because every track's top is the same statement — "this
/// group is at its target" — the tracks are comparable to each other at a glance, which is exactly
/// what a per-group centred tick destroys (the reason the earlier diverging version read as a
/// puzzle). What differs between groups is how full they are, and nothing else.
///
/// A track's state is `MuscleBalanceEntry.goalState`: partly filled and unbadged while short, then
/// translucent with a check once it is at target, and translucent with a double chevron when it is
/// well past it. Overshoot still counts — the chevron admits it rather than hiding it.
struct MuscleBalanceTrackChart: View {
    /// Already narrowed to targeted groups by the caller (`MuscleBalanceCalculator.goalEntries`).
    let entries: [MuscleBalanceEntry]
    var spacing: CGFloat = 5
    var badgeDiameter: CGFloat = 13
    /// Fullest last, so the gaps read first — matching the Strength chart beside it. Off for the
    /// detail screen's fixed-order variants.
    var sortsByFill: Bool = true

    private var ordered: [MuscleBalanceEntry] {
        guard sortsByFill else { return entries }
        return entries.sorted { ($0.goalFraction ?? 0) < ($1.goalFraction ?? 0) }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: spacing) {
            ForEach(ordered) { entry in
                MuscleBalanceTrack(entry: entry, badgeDiameter: badgeDiameter)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: Text {
        let met = entries.filter { $0.goalState != .under }.count
        let base = String(
            format: NSLocalizedString("muscleBalanceGoalAccessibility", comment: ""),
            met, entries.count
        )
        let short = entries.filter { $0.goalState == .under }
            .sorted { ($0.goalFraction ?? 0) < ($1.goalFraction ?? 0) }
            .prefix(2)
            .map(\.muscleGroup.description)
        guard !short.isEmpty else { return Text(base) }
        return Text(base + ", " + short.joined(separator: ", "))
    }
}

/// One muscle group's filling track, normalised to its own target — the shared bar behind both the
/// chart above and the overview's cells, so the two can never drift apart.
struct MuscleBalanceTrack: View {
    let entry: MuscleBalanceEntry
    var badgeDiameter: CGFloat = 13

    var body: some View {
        let color = entry.muscleGroup.color
        let fraction = min(entry.goalFraction ?? 0, 1)
        let isMet = entry.goalState != .under
        return GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // The unfilled remainder stays visible on every track, so "not there yet" is a
                // shape rather than something you infer from the absence of a badge. An untrained
                // group keeps its colour at low alpha: identity without inventing a single set.
                Capsule(style: .continuous)
                    .fill(entry.setCount == 0 ? color.opacity(0.12) : Color.label.opacity(0.07))
                // The fill keeps the track's original near-flat top; the capsule clip below rounds
                // its bottom (and its top once full). A capsule-shaped fill instead shrinks into a
                // circle whenever it is shorter than the track is wide — every low weekly count.
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color.opacity(isMet ? 0.25 : 1))
                    .frame(height: geo.size.height * fraction)
            }
            // Capsule ends to sit with the rounded tiles they stand in.
            .clipShape(Capsule(style: .continuous))
            // Centred on the track rather than laid out by the fill's bottom-aligned stack, which
            // parked every badge on the floor.
            .overlay {
                if isMet {
                    badge(for: entry.goalState, color: color)
                }
            }
        }
    }

    /// The verdict, centred on the filled track. Solid on a translucent fill so it reads as a badge
    /// rather than part of the bar.
    private func badge(for state: MuscleBalanceGoalState, color: Color) -> some View {
        ZStack {
            Circle().fill(color)
            Image(systemName: state == .over ? "chevron.up.2" : "checkmark")
                .font(.system(size: badgeDiameter * (state == .over ? 0.48 : 0.56), weight: .black))
                .foregroundStyle(Color.background)
        }
        .frame(width: badgeDiameter, height: badgeDiameter)
    }
}

/// One muscle group as a compact cell for the Muscle Groups grid: the name at the top, the group's
/// weekly sets over its weekly target ("7/10") at the bottom-leading corner, and its filling track
/// standing full height on the trailing edge.
///
/// The track is literally `MuscleBalanceTrack`, the same bar the hero chart above draws, badge and
/// all: a cell and its bar in the hero say the same thing in the same shape, and the verdict glyph
/// lives in one place instead of being repeated beside the name.
///
/// The cell does not name the group's priority. The grid reads results; priorities are set on the
/// focus editor and on the muscle's own page, and a third place to read them would turn every tile
/// into a comparison between two scales.
struct MuscleBalanceGoalCell: View {
    let entry: MuscleBalanceEntry
    /// A group the user turned off. It keeps its place in the grid — the editor keeps it in place as
    /// "Off" too, so nothing shifts between the two screens — but has no share to read against a
    /// target: its name gives up its colour, the value says Off, and the track stands empty.
    var isExcluded: Bool = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// One height for every cell, so a grid row stays even and every track is measured against the
    /// same span. Dropped at accessibility sizes, where the text has to be free to grow.
    private static let height: CGFloat = 104
    /// The track's height once the cell is no longer fixed-height: it can't fill the leftover space,
    /// so it takes a flat height rather than collapsing.
    private static let accessibilityTrackHeight: CGFloat = 72
    /// Roughly the hero chart's own width-to-height ratio at this cell's height (its tracks run about
    /// 37×130), so the tile's bar reads as one of those bars rather than a thinner cousin.
    private static let trackWidth: CGFloat = 24
    /// Narrower than the track, like the hero's badges — the bar has to stay visible around it.
    private static let badgeDiameter: CGFloat = 16

    private var usesFixedHeight: Bool { !dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                // The chevron says the tile opens the muscle's page, the way "Volume >" does on the
                // Summary's tiles.
                HStack(spacing: 4) {
                    Text(entry.muscleGroup.description)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(isExcluded ? Color.secondaryLabel : entry.muscleGroup.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    NavigationChevron()
                        .foregroundStyle(Color.secondaryLabel)
                }
                Spacer(minLength: 10)
                if isExcluded {
                    Text(NSLocalizedString("musclePriorityOff", comment: ""))
                        .font(.title.weight(.bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.secondaryLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    share
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            if isExcluded {
                Capsule(style: .continuous)
                    .fill(Color.label.opacity(0.07))
                    .frame(width: Self.trackWidth)
                    .frame(maxHeight: usesFixedHeight ? .infinity : Self.accessibilityTrackHeight)
            } else {
                track
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: usesFixedHeight ? Self.height : nil)
        .secondaryTileStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text(
                isExcluded
                    ? entry.muscleGroup.description + ", " + NSLocalizedString("musclePriorityOff", comment: "")
                    : entry.muscleGroup.description + ", "
                        + String(format: NSLocalizedString("muscleBalanceSetsOfTarget", comment: ""), entry.setsPerWeek, entry.target)
            )
        )
        .accessibilityAddTraits(.isButton)
    }

    /// "7/10" over "sets per week": the group's weekly sets over its weekly target, in the goal shape
    /// every other count on these screens uses — 4/8 groups above it, the same pair at hero size on
    /// the muscle's own page. Neutral like every other value in the app: the name and the track
    /// already carry the group's colour, and a coloured number would read as a verdict of its own.
    private var share: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text("\(entry.setsPerWeek)")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.label)
                Text("/\(entry.target)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.secondaryLabel)
            }
            .fontDesign(.rounded)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            Text(NSLocalizedString("setsPerWeekCaption", comment: ""))
                .font(.caption2)
                .foregroundStyle(Color.secondaryLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    /// Fills the cell's height at normal sizes; at accessibility sizes the cell grows with its text,
    /// so the track takes a fixed height instead (a `GeometryReader` given no height to work with
    /// would have nothing to divide).
    @ViewBuilder
    private var track: some View {
        if usesFixedHeight {
            MuscleBalanceTrack(entry: entry, badgeDiameter: Self.badgeDiameter)
                .frame(width: Self.trackWidth)
                .frame(maxHeight: .infinity)
        } else {
            MuscleBalanceTrack(entry: entry, badgeDiameter: Self.badgeDiameter)
                .frame(width: Self.trackWidth, height: Self.accessibilityTrackHeight)
        }
    }
}

// MARK: - Weekly sets chart

/// The muscle detail's history: one bar per week (or per month, averaged per week, across a year),
/// each drawn against the target in the same shape the balance tracks use. Behind every bar stands a
/// faint capsule as tall as the weekly target; the bar fills it. A week that met its target fills its
/// capsule, a short one leaves the rest showing, and a week past it rises out of the top — so "three
/// of four weeks on target" reads off the chart without a reference line or an axis.
///
/// Each bar carries its number above it instead of a y-axis, and only the first and last bars are
/// dated once there are more than a handful: the picker above already names the window.
struct MuscleWeeklySetsChart: View {
    let bins: [MuscleWeeklySets.Bin]
    /// One per bin, in order (`MuscleWeeklySets.label(for:window:)`).
    let labels: [String]
    /// The weekly set target; 0 draws bars with no capsules behind them.
    let target: Int
    let color: Color

    private static let plotHeight: CGFloat = 132
    /// Room reserved above the tallest bar for its number.
    private static let valueRoom: CGFloat = 20
    /// Wide bars stop here, so four weeks read as four capsules rather than four slabs.
    private static let maxBarWidth: CGFloat = 40

    private var labelsEveryBar: Bool { bins.count <= 6 }
    private var spacing: CGFloat { bins.count > 6 ? 6 : 12 }

    var body: some View {
        let top = CGFloat(max(target, bins.map(\.setsPerWeek).max() ?? 0, 1))
        return VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(bins) { bin in
                    column(bin, top: top)
                }
            }
            .frame(height: Self.plotHeight)
            axisLabels
        }
        .animation(.snappy(duration: 0.3), value: bins)
        .animation(.snappy(duration: 0.25), value: target)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(NSLocalizedString("setsPerWeekTitle", comment: "")))
        .accessibilityValue(Text(accessibilityValue))
    }

    /// A bar and its number. The capsule clip is as tall as whichever is taller — the target or the
    /// week — so a short week fills the bottom of its target capsule with a flat top, and a week past
    /// target is itself a capsule standing out of it. The part past the target is drawn lighter, so
    /// the target stays readable inside a bar that exceeds it.
    ///
    /// With no target there is no capsule to fill, so the clip is the whole plot height, drawn
    /// invisibly: bars keep flat tops and round bottoms instead of shrinking into ovals.
    private func column(_ bin: MuscleWeeklySets.Bin, top: CGFloat) -> some View {
        let unit = (Self.plotHeight - Self.valueRoom) / top
        let targetHeight = CGFloat(target) * unit
        let barHeight = CGFloat(bin.setsPerWeek) * unit
        let exceeds = target > 0 && barHeight > targetHeight
        let clipHeight = target > 0 ? max(targetHeight, barHeight) : top * unit
        return ZStack(alignment: .bottom) {
            if target > 0 {
                // The same neutral remainder the balance tracks draw.
                Rectangle()
                    .fill(Color.label.opacity(0.07))
                    .frame(height: targetHeight)
            }
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(color.opacity(exceeds ? 0.45 : 1))
                .frame(height: barHeight)
            if exceeds {
                Rectangle()
                    .fill(color)
                    .frame(height: targetHeight)
            }
        }
        .frame(height: clipHeight, alignment: .bottom)
        .frame(maxWidth: Self.maxBarWidth)
        .clipShape(Capsule(style: .continuous))
        // The number rides just above the bar — or above the target capsule when the week is short —
        // wherever that is, rather than at the top of the clip.
        .overlay(alignment: .bottom) {
            Text(bin.setsPerWeek > 0 ? "\(bin.setsPerWeek)" : "")
                .font((labelsEveryBar ? Font.caption : Font.caption2).weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(Color.secondaryLabel)
                .lineLimit(1)
                .fixedSize()
                .offset(y: -(max(barHeight, targetHeight) + 4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private var axisLabels: some View {
        if labelsEveryBar {
            HStack(spacing: spacing) {
                ForEach(Array(labels.enumerated()), id: \.offset) { _, label in
                    axisLabel(label)
                        .frame(maxWidth: .infinity)
                }
            }
        } else {
            HStack {
                axisLabel(labels.first ?? "")
                Spacer(minLength: 8)
                axisLabel(labels.last ?? "")
            }
        }
    }

    private func axisLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.secondaryLabel)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    /// "Aug 16: 4, Aug 23: 3, …, Target 6".
    private var accessibilityValue: String {
        var parts = zip(labels, bins).map { "\($0): \($1.setsPerWeek)" }
        if target > 0 {
            parts.append(NSLocalizedString("target", comment: "") + " \(target)")
        }
        return parts.joined(separator: ", ")
    }
}

#Preview {
    FetchRequestWrapper(Workout.self) { workouts in
        let calculator = MuscleBalanceCalculator(workouts: workouts, focus: .default, weeks: 4)
        VStack(spacing: 24) {
            MuscleBalanceTrackChart(entries: calculator.goalEntries)
                .frame(height: 90)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(calculator.goalEntries) { MuscleBalanceGoalCell(entry: $0) }
            }
        }
        .padding()
    }
    .previewEnvironmentObjects()
}
