//
//  WorkoutTemplateDetail.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 08.04.22.
//

import Foundation
import CoreData

final class WorkoutTemplateDetail: ObservableObject {
    
    private var database = Database.shared
    private var workoutTemplateID: NSManagedObjectID
    
    public init(workoutTemplateID: NSManagedObjectID) {
        self.workoutTemplateID = workoutTemplateID
    }
    
    public var workoutTemplate: TemplateWorkout {
        database.object(with: workoutTemplateID) as? TemplateWorkout ?? TemplateWorkout()
    }
    
    public var workouts: [Workout] {
        workoutTemplate.workouts?.array as? [Workout] ?? .emptyList
    }
    
    public var lastUsedDateString: String {
        workouts.first?.date?.description(.medium) ?? NSLocalizedString("never", comment: "")
    }
    
    public func deleteWorkoutTemplate() {
        database.delete(workoutTemplate)
    }
    
    //MARK: - Graph Stuff
    
    @Published var selectedCalendarComponent: Calendar.Component = .weekOfYear
    
    public var graphYValues: [Int] {
        let numberOfValues = numberOfValues(for: selectedCalendarComponent)
        var result = [Int](repeating: 0, count: numberOfValues)
        for i in 0..<numberOfValues {
            if let iteratedDay = Calendar.current.date(byAdding: selectedCalendarComponent, value: -i, to: Date()) {
                workouts
                    .compactMap { $0.date }
                    .forEach { date in
                        if Calendar.current.isDate(date, equalTo: iteratedDay, toGranularity: selectedCalendarComponent) {
                            result[i] += 1
                        }
                    }
            }
        }
        return result.reversed()
    }
    
    public var graphXValues: [String] {
        var result = [String]()
        for i in 0..<numberOfValues(for: selectedCalendarComponent) {
            if let iteratedDay = Calendar.current.date(byAdding: selectedCalendarComponent, value: -i, to: Date()) {
                result.append(getFirstDayString(in: selectedCalendarComponent, for: iteratedDay))
            }
        }
        return result.reversed()
    }
    
    private func numberOfValues(for calendarComponent: Calendar.Component) -> Int {
        switch calendarComponent {
        default: return 5
        }
    }
    
    private func getFirstDayString(in component: Calendar.Component, for date: Date) -> String {
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = component == .weekOfYear ? "dd.MM." : component == .month ? "MMM" : "yyyy"
        return formatter.string(from: firstDayOfWeek)
    }
    
}
