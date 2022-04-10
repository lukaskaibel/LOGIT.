//
//  Array+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.03.22.
//

import Foundation

extension Array {
    
    static var emptyList: [Element] { [Element]() }
    
    func elements(for indexSet: IndexSet) -> [Element] {
        var result = [Element]()
        for i in indexSet {
            result.append(self[i])
        }
        return result
    }
    
}

extension Array where Element: Comparable {
    
    mutating func remove(_ element: Element) {
        self = self.filter { $0 != element }
    }
    
}

