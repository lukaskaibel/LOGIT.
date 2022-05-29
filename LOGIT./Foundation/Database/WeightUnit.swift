//
//  WeightUnit.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 15.03.22.
//

import Foundation

enum WeightUnit: String, Codable, Identifiable {
    
    case kg, lbs

    static var used: WeightUnit {
        WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    }
    
    var id: String {
        self.rawValue
    }
    
}

//MARK: - Functions for translating weight from grams to kilograms or pounds

private let KG_TO_GRAMS: Int = 1000
private let LBS_TO_GRAMS: Int = 454

public func convertWeightForStoring(_ value: Int64) -> Int64 {
    let unit = WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    switch unit {
    case .kg: return value * Int64(KG_TO_GRAMS)
    case .lbs: return value * Int64(LBS_TO_GRAMS)
    }
}

public func convertWeightForDisplaying(_ value: Int64) -> Int {
    let unit = WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    switch unit {
    case .kg: return Int(round(Float(value) / Float(KG_TO_GRAMS)))
    case .lbs: return Int(round(Float(value) / Float(LBS_TO_GRAMS)))
    }
}

public func convertWeightForDisplaying(_ value: Int) -> Int {
    let unit = WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    switch unit {
    case .kg: return Int(round(Float(value) / Float(KG_TO_GRAMS)))
    case .lbs: return Int(round(Float(value) / Float(LBS_TO_GRAMS)))
    }
}
