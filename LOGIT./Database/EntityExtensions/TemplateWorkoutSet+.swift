//
//  TemplateWorkoutSet+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 10.04.22.
//

import Foundation

extension TemplateWorkoutSet {
    
    var hasEntry: Bool {
        repetitions > 0 || weight > 0
    }
    
}
