//
//  MuscleFocus.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.26.
//

import Foundation

// MARK: - Focus

/// The user's training focus: how many sets each muscle group should get per week. Zero means the
/// group isn't part of the focus — it leaves the balance count and has no target to be read against.
///
/// Absolute weekly sets rather than a share of all sets, for two reasons. A share is zero-sum: adding
/// an arm day lowered the legs share and flipped legs to "below target" without the legs training
/// changing at all. And weekly sets per muscle is the unit programs are actually written in, so a
/// target like "legs 10" needs no explaining and "3 more sets" is something you can do this week.
///
/// Persisted as JSON in `UserDefaults` (see `MuscleFocusStore`) — CloudKit is additive-only, so this
/// setting stays out of Core Data.
struct MuscleFocus: Codable, Equatable {
    /// Weekly set target per group. Groups missing from the dictionary read as 0.
    private var targets: [MuscleGroup: Int]

    /// What a single group's stepper allows. Forty weekly sets for one muscle is well past anything a
    /// program would prescribe, so the cap only stops a runaway press.
    static let targetRange = 0 ... 40

    init(targets: [MuscleGroup: Int]) {
        self.targets = targets.mapValues { Self.clamped($0) }
    }

    // MARK: Reads

    /// The group's weekly set target — 0 when it isn't part of the focus.
    func target(for muscleGroup: MuscleGroup) -> Int {
        targets[muscleGroup] ?? 0
    }

    func isExcluded(_ muscleGroup: MuscleGroup) -> Bool {
        target(for: muscleGroup) == 0
    }

    /// The groups with a target, in canonical order.
    var includedGroups: [MuscleGroup] {
        MuscleGroup.allCases.filter { target(for: $0) > 0 }
    }

    /// Every group's target added up — the week the focus describes.
    var weeklyTotal: Int {
        MuscleGroup.allCases.reduce(0) { $0 + target(for: $1) }
    }

    /// The preset whose targets these are exactly, else `nil` ("Custom").
    var matchingPreset: MuscleFocusPreset? {
        MuscleFocusPreset.allCases.first { $0.focus == self }
    }

    /// The lowest target a group's stepper may reach: 0, unless it is the only group left with a
    /// target — a focus on nothing isn't a focus.
    func minimumTarget(for muscleGroup: MuscleGroup) -> Int {
        includedGroups == [muscleGroup] ? 1 : Self.targetRange.lowerBound
    }

    // MARK: Mutations

    /// Sets a group's weekly target, clamped to `targetRange` and refused below 1 for the last group
    /// with a target.
    mutating func setTarget(_ value: Int, for muscleGroup: MuscleGroup) {
        targets[muscleGroup] = max(Self.clamped(value), minimumTarget(for: muscleGroup))
    }

    /// Takes over a preset's targets.
    mutating func apply(_ preset: MuscleFocusPreset) {
        targets = preset.targets
    }

    // MARK: Equatable

    /// Compared across all 8 groups, so a missing entry and an explicit 0 read as equal.
    static func == (lhs: MuscleFocus, rhs: MuscleFocus) -> Bool {
        MuscleGroup.allCases.allSatisfy { lhs.target(for: $0) == rhs.target(for: $0) }
    }

    // MARK: Codable

    /// On disk: `{"targets": {"legs": 10, …}}`, keyed by the muscle-group raw values.
    ///
    /// Also reads the shape the priority editor wrote before targets were sets —
    /// `{"priorities": {"legs": 3, …}, "excluded": ["cardio"]}` — mapping High / Medium / Low to 10 / 6
    /// / 3 weekly sets and an excluded group to 0.
    private enum CodingKeys: String, CodingKey {
        case targets, priorities, excluded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let raw = try container.decodeIfPresent([String: Int].self, forKey: .targets) {
            targets = Self.groupKeyed(raw).mapValues { Self.clamped($0) }
            return
        }
        let rawPriorities = try container.decode([String: Int].self, forKey: .priorities)
        let excluded = Set((try container.decodeIfPresent([String].self, forKey: .excluded) ?? [])
            .compactMap(MuscleGroup.init(rawValue:)))
        let levels = Self.groupKeyed(rawPriorities)
        targets = MuscleGroup.allCases.reduce(into: [:]) { result, group in
            guard !excluded.contains(group) else {
                result[group] = 0
                return
            }
            switch levels[group] ?? 2 {
            case 3: result[group] = 10
            case 1: result[group] = 3
            default: result[group] = 6
            }
        }
        if includedGroups.isEmpty {
            self = .default
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let raw = Dictionary(uniqueKeysWithValues: MuscleGroup.allCases.map { ($0.rawValue, target(for: $0)) })
        try container.encode(raw, forKey: .targets)
    }

    private static func groupKeyed(_ raw: [String: Int]) -> [MuscleGroup: Int] {
        raw.reduce(into: [:]) { result, pair in
            if let group = MuscleGroup(rawValue: pair.key) {
                result[group] = pair.value
            }
        }
    }

    private static func clamped(_ value: Int) -> Int {
        min(max(value, targetRange.lowerBound), targetRange.upperBound)
    }

    // MARK: Defaults

    /// The order every focus surface lists the groups in — the editor's grid, the Muscle Groups grid,
    /// the split bar — descending by the default focus, so a group sits in the same place on each.
    static let displayOrder: [MuscleGroup] = [.legs, .back, .chest, .shoulders, .biceps, .triceps, .abdominals, .cardio]

    /// The app's default focus.
    static var `default`: MuscleFocus { MuscleFocusPreset.fullBody.focus }

    // MARK: Legacy percent split

    /// Reads a split saved by the original percent editor (`[group: percent]`, summing to 100). Its
    /// three exact presets map to their successors; anything else is scaled onto the default focus's
    /// weekly total, keeping at least one set for any group that had a share at all.
    init(legacyPercentages percentages: [MuscleGroup: Int]) {
        func matches(_ preset: [MuscleGroup: Int]) -> Bool {
            MuscleGroup.allCases.allSatisfy { (percentages[$0] ?? 0) == (preset[$0] ?? 0) }
        }
        if matches(Self.legacyBalanced) || matches(Self.legacyPushPullLegs) {
            self = MuscleFocusPreset.fullBody.focus
            return
        }
        if matches(Self.legacyUpperFocus) {
            self = MuscleFocusPreset.upperBody.focus
            return
        }
        let total = percentages.values.reduce(0, +)
        guard total > 0 else {
            self = .default
            return
        }
        let budget = Double(MuscleFocus.default.weeklyTotal)
        self.init(targets: MuscleGroup.allCases.reduce(into: [:]) { result, group in
            let percent = percentages[group] ?? 0
            result[group] = percent > 0 ? max(Int((Double(percent) / Double(total) * budget).rounded()), 1) : 0
        })
    }

    private static let legacyBalanced: [MuscleGroup: Int] = [
        .legs: 20, .back: 18, .chest: 16, .shoulders: 13, .biceps: 9, .triceps: 9, .abdominals: 9, .cardio: 6,
    ]
    private static let legacyUpperFocus: [MuscleGroup: Int] = [
        .chest: 18, .back: 18, .shoulders: 16, .biceps: 13, .triceps: 13, .legs: 12, .abdominals: 6, .cardio: 4,
    ]
    private static let legacyPushPullLegs: [MuscleGroup: Int] = [
        .legs: 22, .back: 16, .chest: 16, .shoulders: 14, .triceps: 11, .biceps: 11, .abdominals: 6, .cardio: 4,
    ]
}

// MARK: - Presets

/// Opinionated starting points, named for what people actually train for — each a full week of set
/// targets. The major groups sit around the ten weekly sets that most hypertrophy guidance treats as a
/// solid baseline, so a lifter training three or four times a week can meet the default rather than
/// trail it on every group. Any stepper change makes the focus "Custom".
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

    /// Weekly sets per group.
    var targets: [MuscleGroup: Int] {
        switch self {
        case .fullBody:
            return [.legs: 10, .back: 10, .chest: 10, .shoulders: 8, .biceps: 6, .triceps: 6, .abdominals: 4, .cardio: 2]
        case .upperBody:
            return [.legs: 4, .back: 12, .chest: 12, .shoulders: 10, .biceps: 8, .triceps: 8, .abdominals: 4, .cardio: 2]
        case .lowerBody:
            return [.legs: 16, .back: 8, .chest: 4, .shoulders: 4, .biceps: 3, .triceps: 3, .abdominals: 6, .cardio: 2]
        case .endurance:
            return [.legs: 10, .back: 6, .chest: 3, .shoulders: 3, .biceps: 2, .triceps: 2, .abdominals: 6, .cardio: 6]
        }
    }

    var focus: MuscleFocus { MuscleFocus(targets: targets) }
}
