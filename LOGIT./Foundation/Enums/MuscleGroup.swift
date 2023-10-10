//
//  MuscleGroup.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.04.22.
//

import SwiftUI

enum MuscleGroup: String, Decodable, Identifiable, CaseIterable {

    case chest, triceps, shoulders, biceps, back, legs, abdominals, cardio

    var id: String { self.rawValue }

    var description: String {
        NSLocalizedString(self.rawValue, comment: "")
    }

    var color: Color {
        switch self {
        case .chest: return .green
        case .triceps: return .yellow
        case .shoulders: return .orange
        case .biceps: return .mint
        case .back: return .blue
        case .legs: return .pink
        case .abdominals: return .brown
        case .cardio: return .gray
        }
    }

}
