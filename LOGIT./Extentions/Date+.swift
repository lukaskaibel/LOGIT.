//
//  Date+.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 29.09.21.
//

import Foundation


extension Date {
    
    var weekOfYear: DateInterval? {
        Calendar.current.dateInterval(of: .weekOfYear, for: self)
    }
    
    func inSameWeekOfYear(as date: Date) -> Bool {
        return self.weekOfYear == date.weekOfYear
    }
    
}
