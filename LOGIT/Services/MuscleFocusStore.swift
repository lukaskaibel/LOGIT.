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

    /// Whether the user has ever set a focus themselves, as opposed to running on the default. Drives
    /// the Summary's one-time focus tip and the "Default" caption on Muscle Groups. A split carried
    /// over from the old percent editor counts: someone who tuned percentages has made that choice.
    ///
    /// Kept in memory once known rather than re-read from disk, because a scenario launch pins reads
    /// of the storage key for the whole session and a re-read would never see the write.
    @Published private(set) var hasChosenFocus: Bool

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = Self.load(from: defaults)
        let migrated = stored == nil ? Self.migrateLegacySplit(from: defaults) : nil
        let focus = stored ?? migrated ?? .default
        self.focus = focus
        split = focus.split
        hasChosenFocus = stored != nil || migrated != nil
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

    /// Every mutation is a choice, even one that changes nothing: picking Full Body while running on
    /// the Full Body default is the user settling on it, and it is persisted so the next launch
    /// remembers that rather than asking again.
    private func commit(_ updated: MuscleFocus) {
        if updated != focus {
            focus = updated
        }
        hasChosenFocus = true
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
