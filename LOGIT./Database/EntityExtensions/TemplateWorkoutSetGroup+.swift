//
//  TemplateWorkoutSetGroup+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation

extension TemplateWorkoutSetGroup {
    
    func index(of set: TemplateWorkoutSet) -> Int? {
        (sets?.array as? [TemplateWorkoutSet])?.firstIndex(of: set)
    }

    
}
