//
//  WorkoutTemplateList.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import Foundation

final class WorkoutTemplateList: ObservableObject {
    
    private var database = Database.shared
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .databaseDidChange, object: nil)
    }
    
    public var templateWorkouts: [TemplateWorkout] {
        database.fetch(TemplateWorkout.self, sortingKey: "creationDate", ascending: false) as! [TemplateWorkout]
    }
    
    public func delete(_ workoutTemplate: TemplateWorkout) {
        database.delete(workoutTemplate, saveContext: true)
    }
    
    @objc private func updateView() {
        objectWillChange.send()
    }
    
}
