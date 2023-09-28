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
        
        case .targetPerWeek: return false
        case .muscleGroupsInLastTen: return true
        case .setsPerWeek: return true
            
        case .measurement(_): return true
        }
    }

}

enum WidgetType {
    case personalBest, bestWeightPerDay, bestRepetitionsPerDay, volumePerDay
    case measurement(MeasurementEntryType)
    case targetPerWeek, muscleGroupsInLastTen, setsPerWeek

    init?(rawValue: String) {
        if rawValue.hasPrefix("measurement") {
            let measurementValue = String(rawValue.dropFirst("measurement".count))
                .firstLetterLowercased
            if let measurementType = MeasurementEntryType(rawValue: measurementValue) {
                self = .measurement(measurementType)
                return
            }
        }
        switch rawValue {
        case "personalBest":
            self = .personalBest
        case "bestWeightPerDay":
            self = .bestWeightPerDay
        case "bestRepetitionsPerDay":
            self = .bestRepetitionsPerDay
        case "volumePerDay":
            self = .volumePerDay
            
        case "targetPerWeek":
            self = .targetPerWeek
        case "muscleGroupsInLastTen":
            self = .muscleGroupsInLastTen
        case "setsPerWeek":
            self = .setsPerWeek
        default:
            return nil
        }
    }

    var rawValue: String {
        switch self {
        case .personalBest:
            return "personalBest"
        case .bestWeightPerDay:
            return "bestWeightPerDay"
        case .bestRepetitionsPerDay:
            return "bestRepetitionsPerDay"
        case .volumePerDay:
            return "volumePerDay"
            
        case .targetPerWeek:
            return "targetPerWeek"
        case .muscleGroupsInLastTen:
            return "muscleGroupsInLastTen"
        case .setsPerWeek:
            return "setsPerWeek"
            
        case .measurement(let measurementType):
            return "measurement" + measurementType.rawValue.firstLetterUppercased
        }
    }
}

extension WidgetType: Equatable {
    static func == (lhs: WidgetType, rhs: WidgetType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
