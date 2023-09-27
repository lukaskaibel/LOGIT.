//
//  MeasurementEntry+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 19.09.23.
//

import Foundation

extension MeasurementEntry {

    var type: MeasurementEntryType? {
        get {
            MeasurementEntryType(rawValue: type_ ?? "")
        }
        set {
            type_ = newValue?.rawValue
        }
    }

    var value: Int {
        get {
            switch type {
            case .bodyweight: return convertWeightForDisplaying(value_)
            case .percentage, .calories: return Int(value_ / 1000)
            case .length: return Int(value_ / 10)
            case .none: return Int(value_)
            }
        }
        set {
            switch type {
            case .bodyweight: value_ = convertWeightForStoring(Int64(newValue))
            case .percentage, .calories: value_ = Int64(newValue * 1000)
            case .length: value_ = Int64(newValue * 10)
            case .none: value_ = Int64(newValue)
            }
        }
    }

}

enum MeasurementEntryType {
    case bodyweight
    case percentage
    case calories
    case length(LengthMeasurementEntryType)

    init?(rawValue: String) {
        if rawValue.hasPrefix("length") {
            let lengthMeasurementTypeRaw = String(rawValue.dropFirst("length".count))
                .firstLetterLowercased
            if let lengthType = LengthMeasurementEntryType(rawValue: lengthMeasurementTypeRaw) {
                self = .length(lengthType)
                return
            }
        }
        switch rawValue {
        case "bodyweight":
            self = .bodyweight
        case "percentage":
            self = .percentage
        case "calories":
            self = .calories
        default:
            return nil
        }
    }

    var rawValue: String {
        switch self {
        case .bodyweight:
            return "bodyweight"
        case .percentage:
            return "percentage"
        case .calories:
            return "calories"
        case .length(let lengthType):
            return "length" + lengthType.rawValue.firstLetterUppercased
        }
    }

    var unit: String {
        switch self {
        case .bodyweight:
            return WeightUnit.used.rawValue
        case .percentage:
            return "%"
        case .calories:
            return "kCal"
        case .length(_):
            return "cm"
        }
    }
}

extension MeasurementEntryType: Equatable {
    static func == (lhs: MeasurementEntryType, rhs: MeasurementEntryType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

enum LengthMeasurementEntryType: String, CaseIterable {
    case neck, shoulders, chest, bicepsLeft, bicepsRight, forearmLeft, forearmRight, waist, hips,
        thighLeft, thighRight, calfLeft, calfRight
}
