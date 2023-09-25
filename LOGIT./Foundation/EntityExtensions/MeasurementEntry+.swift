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
            case .bodyWeight: return convertWeightForDisplaying(value_)
            case .percentage, .calories: return Int(value_ / 1000)
            case .length: return Int(value_ / 10)
            case .none: return Int(value_)
            }
        }
        set {
            switch type {
            case .bodyWeight: value_ = convertWeightForStoring(Int64(newValue))
            case .percentage, .calories: value_ = Int64(newValue * 1000)
            case .length: value_ = Int64(newValue * 10)
            case .none: value_ = Int64(newValue)
            }
        }
    }
    
}

enum MeasurementEntryType {
    case bodyWeight
    case percentage
    case calories
    case length(LengthMeasurementEntryType)
    
    init?(rawValue: String) {
        if rawValue.hasPrefix("length") {
            let lengthValue = String(rawValue.dropFirst("length".count)).lowercased()
            if let lengthType = LengthMeasurementEntryType(rawValue: lengthValue) {
                self = .length(lengthType)
                return
            }
        }
        switch rawValue {
        case "bodyweight":
            self = .bodyWeight
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
        case .bodyWeight:
            return "bodyweight"
        case .percentage:
            return "percentage"
        case .calories:
            return "calories"
        case .length(let lengthType):
            return "length" + lengthType.rawValue.capitalized
        }
    }
    
    var unit: String {
        switch self {
        case .bodyWeight:
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
    static func ==(lhs: MeasurementEntryType, rhs: MeasurementEntryType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

enum LengthMeasurementEntryType: String {
    case neck, shoulders, chest, leftBiceps, rightBiceps, leftForearm, rightForearm, waist, hips, leftThigh, rightThigh, leftCalf, rightCalf
}
