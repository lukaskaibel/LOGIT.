//
//  Widget+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.09.23.
//

import Foundation

extension Widget {

    var type: WidgetType {
        return WidgetType(rawValue: id!)!
    }

    var isProFeature: Bool {
        switch self.type {
        case .personalBest: return false
        case .bestWeightPerDay: return true
        case .bestRepetitionsPerDay: return true
        case .volumePerDay: return true
        case .exerciseSetsPerWeek: return true
        
        case .targetPerWeek: return false
        case .muscleGroupsInLastTen: return true
        case .setsPerWeek: return true
        case .workoutsPerMonth: return true
        case .homeScreenVolumePerDay: return true
            
        case .measurement(_): return true
        }
    }

}

