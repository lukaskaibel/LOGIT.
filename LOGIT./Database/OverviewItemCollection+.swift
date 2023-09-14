//
//  OverviewItemCollection+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.09.23.
//

import Foundation

extension OverviewItemCollection {
    
    enum CollectionType: String {
        case exerciseDetail, homeScreen
    }
    
    var type: CollectionType {
        CollectionType(rawValue: id!)!
    }
    
    var items: [OverviewItem] {
        get {
            return (itemOrder ?? .emptyList)
                .compactMap { id in (items_?.allObjects as? [OverviewItem])?.first { $0.id == id } }
        }
        set {
            itemOrder = newValue.map { $0.id! }
            items_ = NSSet(array: newValue)
        }
    }

}
