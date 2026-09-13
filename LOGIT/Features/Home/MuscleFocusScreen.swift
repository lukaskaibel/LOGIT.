//
//  MuscleFocusScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.26.
//

import SwiftUI

/// The training-focus editor, in two parts: the focus itself — a tappable title over a stacked bar of
/// the week it describes — and the eight muscle groups as a two-column grid, each tile a weekly set
/// target with a native stepper.
///
/// Targets are real numbers of sets per week, not shares and not priority levels: it is the unit
/// programs are written in, it needs no explaining, and unlike a percentage split one group's number
/// never has to move because another's did. The four presets live in the title's menu as ready-made
/// weeks; any stepper change makes the focus "Custom" (the title says so, with nothing checked in the
/// menu). Setting a group to 0 takes it out of the focus.
///
/// Commits on every change through the `MuscleFocusStore`, so the Muscle Groups overview and the
/// Summary's Balance tile update live. Free — it's configuration, not analytics.
struct MuscleFocusScreen: View {
    @EnvironmentObject private var store: MuscleFocusStore

    private static let order = MuscleFocus.displayOrder

    /// The bar, the title and the tiles all sit at this inset, so they line up with each other and
    /// with the list's own cards. Not zero: a row's content is clipped to its bounds, and a bold
    /// rounded capital hard against the leading edge loses a hairline of its stem.
    private static let rowInsets = EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)

    private static let tileCornerRadius: CGFloat = 20

    var body: some View {
        List {
            focusSection
            targetSection
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

    /// The setting's value over the week it describes: the focus's name — a preset's, or "Custom" —
    /// above every group with a target as a segment of one bar, sized by its sets, and the week's total
    /// under it. The bar re-proportions as the steppers move, which shows at a glance where the week's
    /// sets go.
    private var focusSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                MuscleFocusMenu()
                MuscleSplitBar(focus: store.focus, order: Self.order)
                    .frame(height: 24)
                Text(String(format: NSLocalizedString("muscleFocusWeeklyTotal", comment: ""), store.focus.weeklyTotal))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryLabel)
                    .monospacedDigit()
                    // A leading digit's glyph overhangs its frame, and at the row's edge it clips.
                    .padding(.leading, 2)
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.clear)
            .listRowInsets(Self.rowInsets)
            .listRowSeparator(.hidden)
        }
        .listSectionSpacing(.compact)
    }

    // MARK: - Targets

    /// The eight groups, two across. A grid rather than a column because each cell is a name, a
    /// number and a stepper and nothing else — four rows of two put every group on screen at once,
    /// which is what makes the week legible as a whole.
    private var targetSection: some View {
        Section {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(Self.order, id: \.self) { group in
                    targetTile(group)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(Self.rowInsets)
            .listRowSeparator(.hidden)
        } header: {
            Text(NSLocalizedString("setsPerWeekTitle", comment: ""))
        } footer: {
            Text(NSLocalizedString("muscleFocusTargetsFooter", comment: ""))
        }
    }

    /// One group: its name, its weekly target, and a native stepper. The unit lives once, in the
    /// section header, rather than beside eight numbers. A group at 0 gives up its colour — the tile
    /// saying it is out of the focus.
    private func targetTile(_ group: MuscleGroup) -> some View {
        let target = store.focus.target(for: group)
        let isExcluded = target == 0
        return VStack(alignment: .leading, spacing: 6) {
            // Muscle names carry their colour themselves — bold, rounded, no identity dot.
            Text(group.description)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(isExcluded ? Color.secondaryLabel : group.color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            HStack(alignment: .center, spacing: 8) {
                Text("\(target)")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(isExcluded ? Color.secondaryLabel : Color.label)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                Stepper(
                    group.description,
                    value: Binding(
                        get: { store.focus.target(for: group) },
                        set: { store.setTarget($0, for: group) }
                    ),
                    // The last group with a target can't reach 0 — a focus on nothing isn't a focus.
                    in: store.focus.minimumTarget(for: group) ... MuscleFocus.targetRange.upperBound
                )
                .labelsHidden()
                .accessibilityIdentifier("muscleTargetStepper_\(group.rawValue)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CELL_PADDING)
        .background {
            RoundedRectangle(cornerRadius: Self.tileCornerRadius, style: .continuous)
                .fill(Color.secondaryBackground)
        }
    }
}

// MARK: - Focus menu

/// The focus as a control: its name — a preset's, or "Custom" — with a chevron, opening the four
/// presets with the current one checked. Shared by the editor and the Muscle Groups screen, so the
/// setting reads and changes the same way wherever it appears.
///
/// "Custom" is never an item. It isn't something you pick; it is what the focus becomes when a
/// target changes, so it only ever appears as the title with nothing checked.
struct MuscleFocusMenu: View {
    /// Adds an "Edit Targets" item — the way into the full editor from surfaces that aren't it.
    var onEditTargets: (() -> Void)? = nil

    @EnvironmentObject private var store: MuscleFocusStore

    var body: some View {
        let selection = Binding<MuscleFocusPreset?>(
            get: { store.focus.matchingPreset },
            set: { newValue in
                guard let newValue else { return }
                store.apply(preset: newValue)
            }
        )
        Menu {
            Picker(NSLocalizedString("trainingFocus", comment: ""), selection: selection) {
                ForEach(MuscleFocusPreset.allCases) { preset in
                    Text("\(preset.emoji)  \(preset.title)").tag(Optional(preset))
                }
            }
            if let onEditTargets {
                Divider()
                Button(action: onEditTargets) {
                    Label(NSLocalizedString("muscleFocusEditTargets", comment: ""), systemImage: "slider.horizontal.3")
                }
            }
        } label: {
            HStack(spacing: 7) {
                Text(store.focus.matchingPreset?.title ?? NSLocalizedString("muscleFocusCustom", comment: ""))
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
        // Deliberately unstretched — callers align it leading. A menu hit-tests only the content its
        // label draws, so widening it to the row would leave the control dead everywhere except on
        // the words, while still reporting the full width to accessibility: VoiceOver and any
        // synthetic tap would aim at the middle of that empty box and miss.
        .accessibilityIdentifier("muscleFocusMenu")
    }
}

// MARK: - Split bar

/// One stacked bar of a focus's week, each group with a target a segment in its own colour sized by
/// its sets, in the given order. Segments animate as targets change; a group at 0 has no segment.
struct MuscleSplitBar: View {
    let focus: MuscleFocus
    let order: [MuscleGroup]

    private let gap: CGFloat = 2

    private var segments: [MuscleGroup] {
        order.filter { focus.target(for: $0) > 0 }
    }

    var body: some View {
        GeometryReader { geometry in
            let segments = self.segments
            let total = CGFloat(max(focus.weeklyTotal, 1))
            let available = max(geometry.size.width - gap * CGFloat(max(segments.count - 1, 0)), 0)
            HStack(spacing: gap) {
                ForEach(segments, id: \.self) { group in
                    Rectangle()
                        .fill(group.color)
                        .frame(width: available * CGFloat(focus.target(for: group)) / total)
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
