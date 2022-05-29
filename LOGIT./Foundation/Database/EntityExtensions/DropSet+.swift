//
//  DropSet+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import Foundation

extension DropSet {
    
    public func addDrop() {
        repetitions?.append(0)
        weights?.append(0)
    }
    
    public func removeLastDrop() {
        if repetitions?.count ?? 0 > 1 && weights?.count ?? 0 > 1 {
            repetitions?.removeLast()
            weights?.removeLast()
        }
    }
    
    //MARK: Overrides from WorkoutSet
    
    public override var maxRepetitions: Int {
        return Int(repetitions?.max() ?? 0)
    }
    
    public override var maxWeight: Int {
        return Int(weights?.max() ?? 0)
    }
    
    public override var hasEntry: Bool {
        (repetitions?.reduce(0, +) ?? 0) + (weights?.reduce(0, +) ?? 0) > 0
    }
    
    public override func clearEntries() {
        repetitions = Array(repeating: 0, count: repetitions?.count ?? 0)
        weights = Array(repeating: 0, count: weights?.count ?? 0)
    }
    
}
