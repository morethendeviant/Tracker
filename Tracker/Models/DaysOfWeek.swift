//
//  DaysOfWeek.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

enum DayOfWeek: Int, CaseIterable {
    case sun, mon, tue, wed, thu, fri, sat
}

extension DayOfWeek {
    private static func dayIndexFor(dayNumber: Int, calendar: Calendar = Calendar.current) -> Int {
        let day = dayNumber + calendar.firstWeekday - 1
        return day > 6 ? 7 - day : day
    }
    
    static func dayFromNumber(_ dayNumber: Int) -> Self {
        Self.allCases[dayIndexFor(dayNumber: dayNumber)]
    }
    
    static func fullNameFor(_ dayNumber: Int) -> String? {
        let days = Calendar.current.weekdaySymbols
        guard 0..<days.count ~= dayNumber else { return nil }
        return days[dayIndexFor(dayNumber: dayNumber)]
    }
    
    static func fullNameFor( _ day: Self) -> String? {
        fullNameFor(day.rawValue)
    }
    
    static func shortNameFor(_ dayNumber: Int) -> String? {
        let days = Calendar.current.shortWeekdaySymbols
        guard 0..<days.count ~= dayNumber else { return nil }
        return days[dayNumber]
    }
    
    static func shortNameFor(_ day: Self) -> String? {
        shortNameFor(day.rawValue)
    }
    
    static func shortNamesFor(_ days: [Self]) -> String? {
        let everyDayText = NSLocalizedString("everyDay", comment: "Every day")
        return days.count == 7 ? everyDayText : days.compactMap { shortNameFor($0) }.joined(separator: ", ")
    }
    
    static func daysToNumbers(_ days: [Self]) -> String {
        Self.allCases.map { days.contains($0) ? "\($0.rawValue + 1)" : "0" }.joined()
    }
    
    static func numbersToDays(_ binaryString: String) -> [Self] {
        var days: [Self] = []
        binaryString.enumerated().forEach { if Int(String($1)) != 0 { days.append(Self.allCases[$0]) }  }
        return days
    }
    
    static func dayToNumber(_ day: Self) -> String {
        String(day.rawValue + 1)
    }
    
    static var count: Int {
        Self.allCases.count
    }
}
