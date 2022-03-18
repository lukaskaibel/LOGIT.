//
//  Array+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.03.22.
//

import Foundation


extension Array {
    
    static var emptyList: [Element] { [Element]() }
    
}

extension Array where Element: Comparable {
    
    mutating func remove(_ element: Element) {
        self = self.filter { $0 != element }
    }
    
}
