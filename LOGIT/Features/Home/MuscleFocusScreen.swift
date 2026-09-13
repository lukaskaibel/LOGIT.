//
//  MuscleFocusScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.26.
//

import SwiftUI

/// The training-focus editor, in two parts: the focus itself — a tappable title over the stacked bar
/// of the split it implies — and the eight muscle groups as a two-column grid, each tile a menu of
/// High / Medium / Low, or Off to leave the group out.
///
/// It replaced a per-group percent stepper list with a live "Total" that had to be balanced to 100
/// by hand. Nobody thinks about their training in percentage points; they think "legs first, cardio
/// not at all" — so that is the whole vocabulary here, and the percentages are derived
/// (`MuscleFocus.split`) and drawn only as the bar. Neither the title nor the tiles repeat a group's
/// share: a number beside a control that cannot set it invites exactly the arithmetic this redesign
/// removes, and eight of them turn a settings screen back into a spreadsheet.
///
/// The four presets live **in** the title rather than in a block of their own. They are the value of
/// one setting, not eight competing calls to action, so they belong behind the control that reads
/// that value — which is what the chevron says. It also buys the screen back the space a preset
/// section was spending, so the groups sit above the fold in a grid instead of a long column.
///
/// Presets are starting points: any priority change makes the focus "Custom" (the title says so,
/// with nothing checked in the menu), while turning a group off is orthogonal and survives a preset
/// switch (see `MuscleFocus`). Commits on every change through the `MuscleFocusStore`, so the Muscle
/// Groups overview and the Summary's Balance tile update live. Free — it's configuration, not
/// analytics.
struct MuscleFocusScreen: View {
    @EnvironmentObject private var store: MuscleFocusStore

    /// Descending by the default focus, so the grid reads big to small.
    private static let order: [MuscleGroup] = [.legs, .back, .chest, .shoulders, .biceps, .triceps, .abdominals, .cardio]

    /// The bar, the title and the tiles all sit at this inset, so they line up with each other and
    /// with the list's own cards. Not zero: a row's content is clipped to its bounds, and a bold
    /// rounded capital hard against the leading edge loses a hairline of its stem.
    private static let rowInsets = EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)

    private static let tileCornerRadius: CGFloat = 20

    private var currentTitle: String {
        store.focus.matchingPreset?.title ?? NSLocalizedString("muscleFocusCustom", comment: "")
    }

    var body: some View {
        List {
            focusSection
            prioritySection
        }
        .scrollContentBackground(.hidden)
        .background(Color.background)
        .contentMargins(.bottom, SCROLLVIEW_BOTTOM_PADDING, for: .scrollContent)
        .animation(.snappy(duration: 0.3), value: store.focus)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(NSLocalizedString("trainingFocus", comment: ""))
                    .font(.headline)
            }
        }
    }

    // MARK: - Focus

    /// The setting's value over what it comes out as: the focus's name — a preset's, or "Custom" —
    /// above every included group as a segment of one bar, sized by its target share. The bar
    /// re-proportions as the focus and the priorities change, which is the whole explanation of what
    /// a priority does, and the only place the split is quantified at all.
    private var focusSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                focusMenu
                MuscleSplitBar(split: store.split, order: Self.order)
                    .frame(height: 24)
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.clear)
            .listRowInsets(Self.rowInsets)
            .listRowSeparator(.hidden)
        }
        .listSectionSpacing(.compact)
    }

    /// The title is the control: tapping it offers the four presets, each with its glyph, the
    /// current one checked. "Custom" is never an item — it isn't something you pick, it is what the
    /// focus becomes when you change a priority below, so it only ever appears as the title with
    /// nothing checked.
    private var focusMenu: some View {
        let selection = Binding<MuscleFocusPreset?>(
            get: { store.focus.matchingPreset },
            set: { newValue in
                guard let newValue else { return }
                store.apply(preset: newValue)
            }
        )
        return Menu {
            Picker(NSLocalizedString("trainingFocus", comment: ""), selection: selection) {
                ForEach(MuscleFocusPreset.allCases) { preset in
                    Text("\(preset.emoji)  \(preset.title)").tag(Optional(preset))
                }
            }
        } label: {
            HStack(spacing: 7) {
                Text(currentTitle)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.label)
                // Down, not up-and-down: this opens a list of choices rather than cycling a value,
                // and it is the glyph a menu-backed title wears everywhere else in iOS.
                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.secondaryLabel)
            }
            .padding(.vertical, 4)
            .padding(.trailing, 6)
            .contentShape(Rectangle())
        }
        // Deliberately unstretched — the enclosing VStack aligns it leading. A menu hit-tests only
        // the content its label draws, so widening it to the row would leave the control dead
        // everywhere except on the words, while still reporting the full width to accessibility:
        // VoiceOver and any synthetic tap would aim at the middle of that empty box and miss.
        .accessibilityIdentifier("muscleFocusMenu")
    }

    // MARK: - Priorities

    /// The eight groups, two across. A grid rather than a column because each cell is a name and a
    /// value and nothing else — half-width rows waste no information, and four rows of two put every
    /// group on screen at once, which is what makes the balance between them legible at all.
    private var prioritySection: some View {
        Section {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(Self.order, id: \.self) { group in
                    priorityTile(group)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(Self.rowInsets)
            .listRowSeparator(.hidden)
        } header: {
            Text(NSLocalizedString("priorities", comment: ""))
        } footer: {
            Text(NSLocalizedString("muscleFocusPrioritiesFooter", comment: ""))
        }
    }

    /// One group: its name and its level, the whole tile being the menu. "Off" is an option of that
    /// same menu rather than a separate toggle — one control per group, and the excluded state reads
    /// in the same place the priority does.
    private func priorityTile(_ group: MuscleGroup) -> some View {
        let isExcluded = store.focus.isExcluded(group)
        // The last included group can't be turned off — a focus on nothing isn't a focus — so the
        // option simply isn't offered for it.
        let offersOff = isExcluded || store.focus.includedGroups.count > 1
        let selection = Binding<MusclePriority?>(
            get: { isExcluded ? nil : store.focus.priority(for: group) },
            set: { newValue in
                if let newValue {
                    store.setPriority(newValue, for: group)
                } else {
                    store.exclude(group)
                }
            }
        )
        // A `Menu` around an inline `Picker` rather than a `.menu`-style picker: the options still
        // come up as the native checkmark list, but the tile is drawn here — a menu picker's own
        // label ignores `.tint` and paints itself in the accent, and eight accent-coloured values
        // read as eight links; the muscle names carry the colour here.
        return Menu {
            Picker(group.description, selection: selection) {
                ForEach(MusclePriority.allCases.reversed()) { priority in
                    Text(priority.title).tag(Optional(priority))
                }
                if offersOff {
                    Text(NSLocalizedString("musclePriorityOff", comment: "")).tag(MusclePriority?.none)
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    // Muscle names carry their colour themselves — bold, rounded, no identity dot.
                    // An excluded group gives that colour up, which is the tile saying it is out.
                    Text(group.description)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(isExcluded ? Color.secondaryLabel : group.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 4)
                    MusclePriorityMeter(
                        level: isExcluded ? nil : store.focus.priority(for: group),
                        color: group.color
                    )
                }
                HStack(spacing: 5) {
                    // Full-strength, not secondary: this is the value the tile is here to state, and
                    // a greyed-out value reads as a disabled control rather than a set one.
                    Text(
                        isExcluded
                            ? NSLocalizedString("musclePriorityOff", comment: "")
                            : store.focus.priority(for: group).title
                    )
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(isExcluded ? Color.secondaryLabel : Color.label)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    // The affordance, and nothing more: tertiary so it never competes with the value.
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.tertiaryLabel)
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(CELL_PADDING)
            .background {
                RoundedRectangle(cornerRadius: Self.tileCornerRadius, style: .continuous)
                    .fill(Color.secondaryBackground)
            }
            .contentShape(RoundedRectangle(cornerRadius: Self.tileCornerRadius, style: .continuous))
        }
        .accessibilityIdentifier("musclePriority_\(group.rawValue)")
    }
}

// MARK: - Priority meter

/// Three ascending bars, filled up to the group's level — the priority as a quantity rather than a
/// word, in the muscle's own colour. It repeats what the tile's value says, which is the point: the
/// word is what you read, the bars are what you compare across eight tiles at a glance. An excluded
/// group shows the empty track, so "Off" has a picture too.
struct MusclePriorityMeter: View {
    /// `nil` when the group is excluded.
    let level: MusclePriority?
    let color: Color

    private static let heights: [CGFloat] = [7, 11, 15]

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(Array(Self.heights.enumerated()), id: \.offset) { index, height in
                Capsule()
                    .fill(index < (level?.weight ?? 0) ? color : Color.fill)
                    .frame(width: 4, height: height)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Split bar

/// One stacked bar of the target split, each included group a segment in its own colour, in the
/// given order. Segments animate as the split changes; a group with no share has no segment.
struct MuscleSplitBar: View {
    let split: MuscleTargetSplit
    let order: [MuscleGroup]

    private let gap: CGFloat = 2

    private var segments: [MuscleGroup] {
        order.filter { split.percentage(for: $0) > 0 }
    }

    var body: some View {
        GeometryReader { geometry in
            let segments = self.segments
            let available = max(geometry.size.width - gap * CGFloat(max(segments.count - 1, 0)), 0)
            HStack(spacing: gap) {
                ForEach(segments, id: \.self) { group in
                    Rectangle()
                        .fill(group.color)
                        .frame(width: available * CGFloat(split.percentage(for: group)) / 100)
                }
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .clipShape(Capsule())
        }
    }
}

private struct PreviewWrapperView: View {
    var body: some View {
        NavigationStack {
            MuscleFocusScreen()
        }
    }
}

struct MuscleFocusScreen_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .previewEnvironmentObjects()
    }
}
