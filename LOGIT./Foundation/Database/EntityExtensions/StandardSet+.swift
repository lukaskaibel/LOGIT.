//
//  WorkoutSet+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 27.06.21.
//

import Foundation


extension StandardSet {
    
    // MARK: Overrides from WorkoutSet
            
    public override var maxRepetitions: Int {
        return Int(repetitions)
    }
    
    public override var maxWeight: Int {
        return Int(weight)
    }
    
    override public var hasEntry: Bool {
        repetitions > 0 || weight > 0
    }
    
    public override func clearEntries() {
        repetitions = 0
        weight = 0
    }
    
}
