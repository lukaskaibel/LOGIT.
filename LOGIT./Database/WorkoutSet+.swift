//
//  WorkoutSet+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 27.06.21.
//

import Foundation


extension WorkoutSet {
    
    public enum Attribute: String {
        case repetitions, time="duration", weight
    }
    
    var exercise: Exercise? {
        setGroup?.exercise
    }
    
    var workout: Workout? {
        setGroup?.workout
    }
    
    func makeCopy() -> WorkoutSet? {
        guard let context = self.managedObjectContext else { return nil }
        let copy = WorkoutSet(context: context)
        copy.setGroup = self.setGroup
        copy.repetitions = self.repetitions
        copy.weight = self.weight
        copy.time = self.time 
        return copy
    }
    
}


extension WorkoutSet {
    
    static func == (lhs: WorkoutSet, rhs: WorkoutSet) -> Bool {
        return lhs.objectID == rhs.objectID
    }
    
}
