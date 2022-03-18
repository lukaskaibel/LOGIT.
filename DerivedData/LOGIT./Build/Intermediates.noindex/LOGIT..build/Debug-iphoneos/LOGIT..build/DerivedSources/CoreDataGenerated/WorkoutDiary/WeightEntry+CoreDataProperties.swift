//
//  WeightEntry+CoreDataProperties.swift
//  
//
//  Created by Lukas Kaibel on 28.02.22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension WeightEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeightEntry> {
        return NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
    }

    @NSManaged public var date: Date?
    @NSManaged public var weight: Int64

}

extension WeightEntry : Identifiable {

}
