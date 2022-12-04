//
//  MuscleGroup.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.04.22.
//

import SwiftUI

enum MuscleGroup: String, Identifiable, CaseIterable {
    
    case chest, back, arms, shoulders, abdominals = "abs", legs
    
    var id: String { self.rawValue }
    
    var description: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
    var color: Color {
        switch self {
        case .chest: return .green
        case .back: return .mint
        case .arms: return .purple
        case .shoulders: return .orange
        case .abdominals: return .indigo
        case .legs: return .pink
        }
    }
    
}
