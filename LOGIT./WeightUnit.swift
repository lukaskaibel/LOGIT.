//
//  WeightUnit.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 15.03.22.
//

import Foundation

enum WeightUnit: String, Codable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case kg, lbs
    
    static var used: WeightUnit {
        WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    }
}

//MARK: - Functions for translating weight from grams to kilograms or pounds

public func convertWeightForStoring(_ value: Int64) -> Int64 {
    let unit = WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    switch unit {
    case .kg: return value * 1000
    case .lbs: return value * 454
    }
}

public func convertWeightForDisplaying(_ value: Int64) -> Int {
    let unit = WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    switch unit {
    case .kg: return Int(round(Float(value) / 1000))
    case .lbs: return Int(round(Float(value) / 454))
    }
}

public func convertWeightForDisplaying(_ value: Int) -> Int {
    let unit = WeightUnit(rawValue: UserDefaults.standard.string(forKey: "weightUnit")!)!
    switch unit {
    case .kg: return Int(round(Float(value) / 1000))
    case .lbs: return Int(round(Float(value) / 454))
    }
}
