//
//  MuscleFocus.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.26.
//

import Foundation

// MARK: - Priority

/// How much attention a muscle group should get relative to the others: three steps, no percentages.
/// The target split is *derived* from these (see `MuscleFocus.split`) — high counts three times as
/// much as low — so the user never balances numbers to 100.
///
/// A group that should not count at all is **excluded** on the `MuscleFocus` rather than given a
/// fourth level here: exclusion is a separate flag, so switching presets never quietly re-includes a
/// group the user turned off.
enum MusclePriority: Int, Codable, CaseIterable, Identifiable, Comparable {
    case low = 1, medium = 2, high = 3

    var id: Int { rawValue }

    /// The share weight the split is apportioned by.
    var weight: Int { rawValue }

    /// Localized name ("High"), used by the editor's per-group menu.
    var title: String { NSLocalizedString("musclePriority_\(key)", comment: "") }

    private var key: String {
        switch self {
        case .low: return "low"
        case .medium: return "medium"
        case .high: return "high"
        }
    }

    static func < (lhs: MusclePriority, rhs: MusclePriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Focus

/// The user's training focus: a priority for every muscle group plus the groups they have turned
/// off. This is what the editor edits and what is persisted; the whole-percent `MuscleTargetSplit`
/// every balance surface reads is derived from it.
///
/// Persisted as JSON in `UserDefaults` (see `MuscleFocusStore`) — CloudKit is additive-only, so the
/// redesign's persistence stays out of Core Data.
struct MuscleFocus: Codable, Equatable {
    /// A priority for every group, kept even while the group is excluded so that turning it back on
    /// restores what it had.
    private var priorities: [MuscleGroup: MusclePriority]
    /// Groups that count for nothing: they leave the split, the chart and the goal's denominator.
    private(set) var excluded: Set<MuscleGroup>

    init(priorities: [MuscleGroup: MusclePriority], excluded: Set<MuscleGroup> = []) {
        self.priorities = priorities
        self.excluded = excluded
    }

    // MARK: Reads

    /// The group's priority, regardless of whether it is excluded. Groups missing from the
    /// dictionary read as medium.
    func priority(for muscleGroup: MuscleGroup) -> MusclePriority {
        priorities[muscleGroup] ?? .medium
    }

    func isExcluded(_ muscleGroup: MuscleGroup) -> Bool {
        excluded.contains(muscleGroup)
    }

    /// The groups the split is divided among, in canonical order.
    var includedGroups: [MuscleGroup] {
        MuscleGroup.allCases.filter { !excluded.contains($0) }
    }

    /// The share weight a group contributes to the split — zero once excluded.
    func weight(for muscleGroup: MuscleGroup) -> Int {
        excluded.contains(muscleGroup) ? 0 : priority(for: muscleGroup).weight
    }

    /// The whole-percent target split these priorities imply.
    var split: MuscleTargetSplit {
        MuscleTargetSplit.apportioned(
            weights: MuscleGroup.allCases.reduce(into: [:]) { $0[$1] = weight(for: $1) }
        )
    }

    /// The preset whose priorities these are, else `nil` ("Custom"). Exclusions don't take part:
    /// "Upper Body with cardio off" is still Upper Body.
    var matchingPreset: MuscleFocusPreset? {
        MuscleFocusPreset.allCases.first { preset in
            MuscleGroup.allCases.allSatisfy { preset.priority(for: $0) == priority(for: $0) }
        }
    }

    // MARK: Mutations

    /// Sets a group's priority and, if it was off, turns it back on.
    mutating func setPriority(_ priority: MusclePriority, for muscleGroup: MuscleGroup) {
        priorities[muscleGroup] = priority
        excluded.remove(muscleGroup)
    }

    /// Leaves a group out of the split. Refused for the last included group — a focus on nothing
    /// isn't a focus.
    mutating func exclude(_ muscleGroup: MuscleGroup) {
        guard includedGroups.count > 1 || excluded.contains(muscleGroup) else { return }
        excluded.insert(muscleGroup)
    }

    mutating func include(_ muscleGroup: MuscleGroup) {
        excluded.remove(muscleGroup)
    }

    /// Takes over a preset's priorities, keeping the current exclusions.
    mutating func apply(_ preset: MuscleFocusPreset) {
        priorities = preset.priorities
    }

    // MARK: Equatable

    /// Compared across all 8 groups, so a missing entry and an explicit medium read as equal.
    static func == (lhs: MuscleFocus, rhs: MuscleFocus) -> Bool {
        lhs.excluded == rhs.excluded
            && MuscleGroup.allCases.allSatisfy { lhs.priority(for: $0) == rhs.priority(for: $0) }
    }

    // MARK: Codable

    /// On disk: `{"priorities": {"legs": 3, …}, "excluded": ["cardio"]}`, keyed by the muscle-group
    /// raw values — an enum-keyed dictionary isn't `Codable` to a JSON object on its own.
    private enum CodingKeys: String, CodingKey {
        case priorities, excluded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawPriorities = try container.decode([String: Int].self, forKey: .priorities)
        priorities = rawPriorities.reduce(into: [:]) { result, pair in
            if let group = MuscleGroup(rawValue: pair.key), let priority = MusclePriority(rawValue: pair.value) {
                result[group] = priority
            }
        }
        let rawExcluded = try container.decodeIfPresent([String].self, forKey: .excluded) ?? []
        excluded = Set(rawExcluded.compactMap(MuscleGroup.init(rawValue:)))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            Dictionary(uniqueKeysWithValues: priorities.map { ($0.key.rawValue, $0.value.rawValue) }),
            forKey: .priorities
        )
        try container.encode(excluded.map(\.rawValue).sorted(), forKey: .excluded)
    }

    // MARK: Defaults

    /// The order every focus surface lists the groups in — the editor's grid, the Muscle Groups grid,
    /// the split bar — descending by the default focus, so a group sits in the same place on each.
    static let displayOrder: [MuscleGroup] = [.legs, .back, .chest, .shoulders, .biceps, .triceps, .abdominals, .cardio]

    /// The app's default focus.
    static var `default`: MuscleFocus { MuscleFocusPreset.fullBody.focus }

    // MARK: Legacy

    /// Reads a split saved by the percent editor this focus replaced. Exact old presets map to their
    /// successors; anything else is quantised against the mean share of the groups it kept — a group
    /// at 130 % of the mean or more reads as high, at 70 % or less as low — and zeroed groups become
    /// exclusions. Best effort: the old editor let every percent drift, and three levels are all the
    /// new one has.
    init(legacy split: MuscleTargetSplit) {
        if let successor = Self.legacyPresetSuccessors.first(where: { $0.split == split })?.successor {
            self = successor.focus
            return
        }
        let included = MuscleGroup.allCases.filter { split.percentage(for: $0) > 0 }
        guard !included.isEmpty else {
            self = .default
            return
        }
        let mean = Double(split.total) / Double(included.count)
        priorities = MuscleGroup.allCases.reduce(into: [:]) { result, group in
            let percent = Double(split.percentage(for: group))
            if percent <= 0 {
                result[group] = .medium
            } else if percent >= mean * 1.3 {
                result[group] = .high
            } else if percent <= mean * 0.7 {
                result[group] = .low
            } else {
                result[group] = .medium
            }
        }
        excluded = Set(MuscleGroup.allCases).subtracting(included)
    }

    /// The percent editor's three presets, verbatim, and what they became.
    private static let legacyPresetSuccessors: [(split: MuscleTargetSplit, successor: MuscleFocusPreset)] = [
        (
            MuscleTargetSplit(percentages: [
                .legs: 20, .back: 18, .chest: 16, .shoulders: 13,
                .biceps: 9, .triceps: 9, .abdominals: 9, .cardio: 6,
            ]),
            .fullBody
        ),
        (
            MuscleTargetSplit(percentages: [
                .chest: 18, .back: 18, .shoulders: 16, .biceps: 13,
                .triceps: 13, .legs: 12, .abdominals: 6, .cardio: 4,
            ]),
            .upperBody
        ),
        (
            MuscleTargetSplit(percentages: [
                .legs: 22, .back: 16, .chest: 16, .shoulders: 14,
                .triceps: 11, .biceps: 11, .abdominals: 6, .cardio: 4,
            ]),
            .fullBody
        ),
    ]
}

// MARK: - Presets

/// Opinionated starting points, named for what people actually train for. Each is a full set of
/// priorities; the editor lists them as a checkmark list, and any priority change makes the focus
/// "Custom".
enum MuscleFocusPreset: String, CaseIterable, Identifiable {
    case fullBody, upperBody, lowerBody, endurance

    var id: String { rawValue }

    /// Localized name ("Upper Body").
    var title: String { NSLocalizedString("muscleFocusPreset_\(rawValue)", comment: "") }

    /// The menu item's glyph. Deliberately an emoji rather than an SF Symbol: these four are body
    /// regions and a running figure, which the emoji set draws literally and the symbol set only
    /// approximates — and they read the same in every locale, so they need no localization.
    var emoji: String {
        switch self {
        case .fullBody: return "🏋️"
        case .upperBody: return "💪"
        case .lowerBody: return "🦵"
        case .endurance: return "🏃"
        }
    }

    var priorities: [MuscleGroup: MusclePriority] {
        switch self {
        case .fullBody:
            return [
                .legs: .high, .back: .high, .chest: .high, .shoulders: .high,
                .biceps: .medium, .triceps: .medium, .abdominals: .low, .cardio: .low,
            ]
        case .upperBody:
            return [
                .chest: .high, .back: .high, .shoulders: .high, .biceps: .high, .triceps: .high,
                .legs: .low, .abdominals: .low, .cardio: .low,
            ]
        case .lowerBody:
            return [
                .legs: .high, .back: .medium, .abdominals: .medium,
                .chest: .low, .shoulders: .low, .biceps: .low, .triceps: .low, .cardio: .low,
            ]
        case .endurance:
            return [
                .cardio: .high, .legs: .high, .back: .medium, .abdominals: .medium,
                .chest: .low, .shoulders: .low, .biceps: .low, .triceps: .low,
            ]
        }
    }

    func priority(for muscleGroup: MuscleGroup) -> MusclePriority {
        priorities[muscleGroup] ?? .medium
    }

    var focus: MuscleFocus { MuscleFocus(priorities: priorities) }
}

// MARK: - Target split

/// The user's target distribution of training across the 8 muscle groups, as whole-percent values
/// summing to 100 (or all zero). Derived from a `MuscleFocus`; every balance surface compares actual
/// shares against it. Still `Codable` so the split the retired percent editor saved can be read once
/// and migrated.
struct MuscleTargetSplit: Codable, Equatable {
    /// Whole-percent target for each muscle group. Groups absent from the dictionary read as 0.
    private var percentages: [MuscleGroup: Int]

    init(percentages: [MuscleGroup: Int]) {
        self.percentages = percentages
    }

    /// A muscle group's whole-percent target (0 when absent or excluded).
    func percentage(for muscleGroup: MuscleGroup) -> Int {
        percentages[muscleGroup] ?? 0
    }

    /// Sum across all 8 groups — 100 for any split with at least one included group.
    var total: Int {
        MuscleGroup.allCases.reduce(0) { $0 + percentage(for: $1) }
    }

    /// Compared across all 8 groups so an absent group and an explicit 0 read as equal.
    static func == (lhs: MuscleTargetSplit, rhs: MuscleTargetSplit) -> Bool {
        MuscleGroup.allCases.allSatisfy { lhs.percentage(for: $0) == rhs.percentage(for: $0) }
    }

    // MARK: Codable

    /// Stored as `[String: Int]` keyed by the muscle-group raw value.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode([String: Int].self)
        percentages = raw.reduce(into: [:]) { result, pair in
            if let group = MuscleGroup(rawValue: pair.key) {
                result[group] = pair.value
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let raw = Dictionary(uniqueKeysWithValues: percentages.map { ($0.key.rawValue, $0.value) })
        try container.encode(raw)
    }

    // MARK: Defaults

    /// How many percentage points past target a group can sit before it counts as over rather than
    /// met — `MuscleBalanceEntry.goalState` reads this.
    static let behindThreshold = 5

    /// The app's default target split — what the default focus implies.
    static var `default`: MuscleTargetSplit { MuscleFocus.default.split }

    // MARK: Apportionment

    /// The split that divides 100 points in proportion to `weights`.
    static func apportioned(weights: [MuscleGroup: Int]) -> MuscleTargetSplit {
        MuscleTargetSplit(percentages: apportion(weights: weights))
    }

    /// Largest-remainder (Hamilton) apportionment of 100 whole points in proportion to `weights`,
    /// so the 8 values sum to exactly 100 rather than drifting from independent rounding. Ties in
    /// the remainders go to the earlier group in canonical order, so the result is deterministic.
    /// Returns an empty map when every weight is zero.
    static func apportion(weights: [MuscleGroup: Int]) -> [MuscleGroup: Int] {
        let total = weights.values.reduce(0, +)
        guard total > 0 else { return [:] }
        var floors: [MuscleGroup: Int] = [:]
        var remainders: [(group: MuscleGroup, fraction: Double)] = []
        var assigned = 0
        for group in MuscleGroup.allCases {
            let exact = Double(weights[group] ?? 0) / Double(total) * 100
            let floored = Int(exact.rounded(.down))
            floors[group] = floored
            assigned += floored
            remainders.append((group, exact - Double(floored)))
        }
        let ordered = remainders.sorted {
            if $0.fraction != $1.fraction { return $0.fraction > $1.fraction }
            let lhs = MuscleGroup.allCases.firstIndex(of: $0.group) ?? 0
            let rhs = MuscleGroup.allCases.firstIndex(of: $1.group) ?? 0
            return lhs < rhs
        }
        var remaining = 100 - assigned
        var index = 0
        while remaining > 0, index < ordered.count {
            floors[ordered[index].group, default: 0] += 1
            remaining -= 1
            index += 1
        }
        return floors
    }
}
