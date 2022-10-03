//
//  MuscleGroup.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.04.22.
//

import SwiftUI

enum MuscleGroup: String, Identifiable, CaseIterable {
    
    case chest, back, arms, shoulders, abdominals, legs
    
    var id: String { self.rawValue }
    
    var description: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
    var color: Color {
        switch self {
        case .chest: return .mint
        case .back: return .green
        case .arms: return .orange
        case .shoulders: return .purple
        case .abdominals: return .yellow
        case .legs: return .blue
        }
    }
    
}
