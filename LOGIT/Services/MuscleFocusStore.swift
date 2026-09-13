//
//  MuscleFocusStore.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 29.06.26.
//

import Combine
import Foundation

/// Persists the user's `MuscleFocus` as JSON in `UserDefaults` (mirrors the pinned-exercise tile
/// pattern — no Core Data, since CloudKit is additive-only) and publishes the `MuscleTargetSplit` it
/// implies. An `ObservableObject` so the focus editor's edits live-update the Muscle Groups overview
/// and the Summary Balance tile that read off it. Injected from `LOGITApp`/`PreviewEnvironmentObjects`.
final class MuscleFocusStore: ObservableObject {
    static let storageKey = "muscleFocus"
    /// Where the retired percent editor kept its split. Read once, when there is no focus yet, so an
    /// existing user's targets carry over; never written again.
    static let legacyStorageKey = "muscleTargetSplit"

    private let defaults: UserDefaults

    /// The current focus. Published so the editor re-renders on every change.
    @Published private(set) var focus: MuscleFocus {
        didSet { split = focus.split }
    }

    /// The target split the focus implies — what every balance surface reads.
    @Published private(set) var split: MuscleTargetSplit

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let focus = Self.load(from: defaults) ?? Self.migrateLegacySplit(from: defaults) ?? .default
        self.focus = focus
        split = focus.split
    }

    // MARK: - Reads

    func target(for muscleGroup: MuscleGroup) -> Int {
        split.percentage(for: muscleGroup)
    }

    // MARK: - Mutations

    func apply(preset: MuscleFocusPreset) {
        var updated = focus
        updated.apply(preset)
        commit(updated)
    }

    /// Sets a group's priority, turning it back on if it was off.
    func setPriority(_ priority: MusclePriority, for muscleGroup: MuscleGroup) {
        var updated = focus
        updated.setPriority(priority, for: muscleGroup)
        commit(updated)
    }

    /// Leaves a group out of the split (a no-op for the last included group).
    func exclude(_ muscleGroup: MuscleGroup) {
        var updated = focus
        updated.exclude(muscleGroup)
        commit(updated)
    }

    private func commit(_ updated: MuscleFocus) {
        guard updated != focus else { return }
        focus = updated
        persist()
    }

    // MARK: - Disk

    private func persist() {
        guard let data = try? JSONEncoder().encode(focus) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    private static func load(from defaults: UserDefaults) -> MuscleFocus? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(MuscleFocus.self, from: data)
    }

    private static func migrateLegacySplit(from defaults: UserDefaults) -> MuscleFocus? {
        guard let data = defaults.data(forKey: legacyStorageKey),
              let split = try? JSONDecoder().decode(MuscleTargetSplit.self, from: data)
        else { return nil }
        return MuscleFocus(legacy: split)
    }
}
