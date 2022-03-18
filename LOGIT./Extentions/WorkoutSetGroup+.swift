//
//  WorkoutSetGroup+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.03.22.
//

import Foundation


extension WorkoutSetGroup {
    
    var isEmpty: Bool {
        sets?.array.isEmpty ?? true
    }
    
    var numberOfSets: Int {
        sets?.array.count ?? 0
    }
    
    subscript(index: Int) -> WorkoutSet {
        get {
            (sets?.array as? [WorkoutSet] ?? .emptyList)[index]
        }
    }
    
    func index(of set: WorkoutSet) -> Int? {
        (sets?.array as? [WorkoutSet])?.firstIndex(of: set)
    }
    
}
