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
        NotificationCenter.default.addObserver(self, selector: #selector(contextChanged), name: .NSManagedObjectContextObjectsDidChange, object: database.container.viewContext)
    }
    
    public var templateWorkouts: [TemplateWorkout] {
        do {
            let request = TemplateWorkout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            return try database.container.viewContext.fetch(request)
        } catch {
            fatalError("Error fetching TemplateWorkouts: \(error)")
        }
    }
    
    public func delete(_ workoutTemplate: TemplateWorkout) {
        database.delete(workoutTemplate, saveContext: true)
    }
    
    @objc private func contextChanged() {
        objectWillChange.send()
    }
    
}
