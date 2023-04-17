//
//  Date + Ext.swift
//  ImageFlow
//
//  Created by Aleksandr Velikanov on 16.12.2022.
//
import Foundation

extension Date {
    func toString(format: String = "dd.MM.yyyy") -> String {
           let formatter = DateFormatter()
           formatter.dateStyle = .short
           formatter.dateFormat = format
           return formatter.string(from: self)
       }
    
    func getDayOfWeek() -> DayOfWeek {
        var customCalendar = Calendar(identifier: .gregorian)
        customCalendar.firstWeekday = 2
        let dayIndex = customCalendar.ordinality(of: .weekday, in: .weekOfYear, for: self)!
        return DayOfWeek.allCases[dayIndex - 1]
    }
    
    func onlyDate() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: self.toCurrentTimezone())
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    func toCurrentTimezone() -> Date {
        let timeZoneDifference = TimeInterval(TimeZone.current.secondsFromGMT())
        return self.addingTimeInterval(timeZoneDifference)
    }
}
