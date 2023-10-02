//
//  WidgetType.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 02.10.23.
//

import Foundation

enum WidgetType {
    case personalBest, bestWeightPerDay, bestRepetitionsPerDay, volumePerDay, exerciseSetsPerWeek
    case measurement(MeasurementEntryType)
    case targetPerWeek, muscleGroupsInLastTen, setsPerWeek, workoutsPerMonth, homeScreenVolumePerDay

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
        case "exerciseSetsPerWeek":
            self = .exerciseSetsPerWeek
            
        case "targetPerWeek":
            self = .targetPerWeek
        case "muscleGroupsInLastTen":
            self = .muscleGroupsInLastTen
        case "setsPerWeek":
            self = .setsPerWeek
        case "workoutsPerMonth":
            self = .workoutsPerMonth
        case "homeScreenVolumePerDay":
            self = .homeScreenVolumePerDay
            
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
        case .exerciseSetsPerWeek:
            return "exerciseSetsPerWeek"
            
        case .targetPerWeek:
            return "targetPerWeek"
        case .muscleGroupsInLastTen:
            return "muscleGroupsInLastTen"
        case .setsPerWeek:
            return "setsPerWeek"
        case .workoutsPerMonth:
            return "workoutsPerMonth"
        case .homeScreenVolumePerDay:
            return "homeScreenVolumePerDay"
            
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
