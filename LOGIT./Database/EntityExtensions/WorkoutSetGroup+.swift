//
//  WorkoutSetGroup+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.03.22.
//

import Foundation


extension WorkoutSetGroup {
    
    public enum SetType: Int {
        case standard, superSet, dropSet
    }
    
    public var isEmpty: Bool {
        sets?.array.isEmpty ?? true
    }
    
    public var numberOfSets: Int {
        sets?.array.count ?? 0
    }
    
    public var setType: SetType {
        let firstSet = sets?.array.first
        if let _ = firstSet as? StandardSet {
            return .standard
        } else if let _ = firstSet as? DropSet {
            return .dropSet
        } else {
            fatalError("SetType not implemented for SuperSet")
        }
    }
    
    public subscript(index: Int) -> WorkoutSet {
        get { (sets?.array as? [WorkoutSet] ?? .emptyList)[index] }
    }
    
    public func index(of set: WorkoutSet) -> Int? {
        (sets?.array as? [WorkoutSet])?.firstIndex(of: set)
    }
    
}
