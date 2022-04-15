//
//  Date+.swift
//  LOGIT
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

    func description(_ style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(self) {
            return NSLocalizedString("today", comment: "")
        } else if Calendar.current.isDateInYesterday(self) {
            return NSLocalizedString("yesterday", comment: "")
        } else if self > Calendar.current.date(byAdding: .day, value: -7, to: Date.now)! {
            formatter.dateFormat = "EEEE"
        } else {
            formatter.dateStyle = style
        }
        return formatter.string(from: self)
    }
}
