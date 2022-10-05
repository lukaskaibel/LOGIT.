//
//  WorkoutTemplateList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import Foundation

final class WorkoutTemplateList: ViewModel {
    
    @Published var searchedText: String = ""
        
    public var templateWorkouts: [TemplateWorkout] {
        database.fetch(TemplateWorkout.self,
                       sortingKey: "creationDate",
                       ascending: false,
                       predicate: searchedText.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@",
                                                                           searchedText)) as! [TemplateWorkout]
    }
    
    public func delete(_ workoutTemplate: TemplateWorkout) {
        database.delete(workoutTemplate, saveContext: true)
    }
    
}
