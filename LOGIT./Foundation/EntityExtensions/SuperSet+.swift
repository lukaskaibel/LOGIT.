//
//  SuperSet+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 25.05.22.
//

import Foundation

extension SuperSet {

    var secondaryExercise: Exercise? {
        setGroup?.secondaryExercise
    }

    // MARK: Overrides from WorkoutSet

    public override var hasEntry: Bool {
        repetitionsFirstExercise > 0 || repetitionsSecondExercise > 0 || weightFirstExercise > 0
            || weightSecondExercise > 0
    }

    public override func clearEntries() {
        repetitionsFirstExercise = 0
        repetitionsSecondExercise = 0
        weightFirstExercise = 0
        weightSecondExercise = 0
    }

}
