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
    
    //MARK: Overrides from WorkoutSet
    
    public override var maxRepetitions: Int {
        return Int(max(repetitionsFirstExercise, repetitionsSecondExercise))
    }
    
    public override var maxWeight: Int {
        return Int(max(weightFirstExercise, weightSecondExercise))
    }
    
    public override var hasEntry: Bool {
        maxRepetitions > 0 || maxWeight > 0
    }
    
    public override func clearEntries() {
        repetitionsFirstExercise = 0
        repetitionsSecondExercise = 0
        weightFirstExercise = 0
        weightSecondExercise = 0
    }
    
}
