//
//  WorkoutTemplateList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import Foundation

final class WorkoutTemplateList: ViewModel {
        
    public var templateWorkouts: [TemplateWorkout] {
        database.fetch(TemplateWorkout.self, sortingKey: "creationDate", ascending: false) as! [TemplateWorkout]
    }
    
    public func delete(_ workoutTemplate: TemplateWorkout) {
        database.delete(workoutTemplate, saveContext: true)
    }
    
}
