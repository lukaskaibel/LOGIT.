//
//  TemplateWorkoutSetGroup+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation

extension TemplateWorkoutSetGroup {
    
    func index(of set: TemplateSet) -> Int? {
        (sets?.array as? [TemplateSet])?.firstIndex(of: set)
    }

    var setType: SetType {
        let firstSet = sets?.array.first
        if let _ = firstSet as? TemplateDropSet {
            return .dropSet
        } else {
            return .standard
        }
    }
    
    @objc enum SetType: Int {
        case standard, superSet, dropSet
    }
    
}
