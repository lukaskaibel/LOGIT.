//
//  MuscleGroup.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.04.22.
//

import Foundation

enum MuscleGroup: String, Identifiable, CaseIterable {
    
    case chest, back, arms, shoulders, abdominals, legs
    
    var id: String { self.rawValue }
    
    var description: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
}
