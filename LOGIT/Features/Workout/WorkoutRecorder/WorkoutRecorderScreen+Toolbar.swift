//
//  WorkoutRecorderScreen+Toolbar.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 14.06.23.
//

import SwiftUI

extension WorkoutRecorderScreen {
    /// The recorder's keyboard accessory: the keyboard's own controls, trailing, under the thumb.
    ///
    /// Hide sits at the very edge and Next inboard of it — the order iOS itself uses, where the
    /// control that puts the keyboard away is the last thing in the bar. Next stands in for the
    /// return key a number pad hasn't got, carrying the session from reps to weight to the next
    /// set's reps, the order the sets are actually filled in. A note or the workout's title brings
    /// hide alone.
    ///
    /// The ± joins Next only while a *weight* field has the keyboard, which is the one moment the
    /// pad's missing minus key is a problem: assistance is stored as a negative weight, and there
    /// is no other way to type one. Two capsules, two jobs: what acts on the field, then what
    /// dismisses the keyboard.
    ///
    /// The rest timer is deliberately *not* in here. It stays the floating control it always was
    /// and slides to the leading edge of this row when a keyboard opens (see
    /// `FloatingChronoControlsOverlay`), which keeps it one view that moves rather than two copies
    /// handing off.
    @ViewBuilder
    var keyboardToolbarContent: some View {
        if focusedIntegerFieldIndex != nil {
            let nextIndex = nextIntegerFieldIndex()
            KeyboardToolbarGroup {
                // Leading of Next, inside its capsule: the ± comes and goes as the field gains and
                // loses a number, and the row is trailing-aligned, so the capsule grows away from
                // the edge and neither Next nor hide — the buttons you tap sixty times a workout —
                // moves under your thumb.
                if let assistedSet = focusedWeightSet {
                    KeyboardAssistedButton(workoutSet: assistedSet)
                }
                KeyboardToolbarTextButton(
                    title: NSLocalizedString("next", comment: ""),
                    isEnabled: nextIndex != nil
                ) {
                    focusedIntegerFieldIndex = nextIndex
                }
                .accessibilityIdentifier("keyboardNextField")
            }
        }
        KeyboardToolbarGroup {
            KeyboardToolbarIconButton(
                systemImage: "keyboard.chevron.compact.down",
                accessibilityLabel: NSLocalizedString("hideKeyboard", comment: "")
            ) {
                focusedIntegerFieldIndex = nil
                dismissKeyboard()
            }
            .accessibilityIdentifier("keyboardHide")
        }
    }

    /// The focused set, but only while the field with the keyboard is its *weight* — the ± acts on
    /// the weight's sign, so it has no business appearing over a reps or duration pad.
    ///
    /// Nil until the field actually holds a number, because a sign flip needs something to flip:
    /// 0 is bodyweight, never "assisted by zero". So the ± arrives with the first digit, the way a
    /// calculator's does — you type the weight, then say it was help rather than load.
    var focusedWeightSet: WorkoutSet? {
        guard let focusedIndex = focusedIntegerFieldIndex,
              let workoutSet = selectedWorkoutSet,
              let entry = workoutSet.entryValues.value(at: focusedIndex.secondary),
              entry.type.weightFieldIndex == focusedIndex.tertiary,
              workoutSet.entryValues.contains(where: { $0.type.usesWeight && $0.weight != 0 })
        else { return nil }
        return workoutSet
    }
}
