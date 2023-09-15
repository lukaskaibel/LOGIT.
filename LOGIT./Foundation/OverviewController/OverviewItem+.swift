//
//  OverviewItem+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.09.23.
//

import Foundation

extension OverviewItem {
    
    enum ItemType: String, CaseIterable {
        case personalBest, bestWeightPerDay, bestRepetitionsPerDay
        case targetPerWeek, muscleGroupsInLastTen, setsPerWeek
    }
    
    var type: ItemType {
        ItemType(rawValue: id!)!
    }
    
    var isProFeature: Bool {
        switch self.type {
        case .personalBest: return false
        case .bestWeightPerDay: return true
        case .bestRepetitionsPerDay: return true
            
        case .targetPerWeek: return false
        case .muscleGroupsInLastTen: return true
        case .setsPerWeek: return true
        }
    }
    
}

