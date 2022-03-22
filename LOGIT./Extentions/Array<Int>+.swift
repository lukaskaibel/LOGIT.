//
//  Array<Int>+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 23.08.21.
//

import Foundation

extension Array where Element: BinaryInteger {
    
    func firstMax() -> Element {
        var max: Element = .zero
        for element in self {
            if element > max { max = element }
        }
        return max
    }
    
    func firstMin() -> Element {
        var min: Element = 10000000000000000        //bad code => should be largest possible value
        for element in self {
            if element < min { min = element }
        }
        return min
    }
    
}
