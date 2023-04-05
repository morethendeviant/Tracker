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
    
    func getDayOfWeek() -> DayOfWeek? {
        var customCalendar = Calendar(identifier: .gregorian)
        customCalendar.firstWeekday = 2
        guard let dayIndex = customCalendar.ordinality(of: .weekday, in: .weekOfYear, for: self) else { return nil }
        return DayOfWeek.allCases[ dayIndex - 1]
    }
    
    func onlyDate() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
}
