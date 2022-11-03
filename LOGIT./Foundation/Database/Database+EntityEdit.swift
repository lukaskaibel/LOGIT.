//
//  Database+EntityEdit.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 03.11.22.
//

import Foundation

extension Database {
  
    public func addSet(to setGroup: WorkoutSetGroup) {
        let lastSet = setGroup.sets.last
        if let _ = lastSet as? DropSet {
            newDropSet(setGroup: setGroup)
        } else if let _ = lastSet as? SuperSet {
            newSuperSet(setGroup: setGroup)
        } else {
            newStandardSet(setGroup: setGroup)
        }
        refreshObjects()
    }
    
}
