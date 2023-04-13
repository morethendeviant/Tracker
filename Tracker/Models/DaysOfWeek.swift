//
//  DaysOfWeek.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

enum DayOfWeek: Int, CaseIterable {
    case mon, tue, wed, thu, fri, sat ,sun
}

extension DayOfWeek {
    static func dayFromNumber(_ dayNumber: Int) -> Self {
        Self.allCases[dayNumber]
    }
    
    static func fullNameFor(_ dayNumber: Int) -> String? {
        let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
        guard 0..<days.count ~= dayNumber else { return nil }
        return days[dayNumber]
    }
    
    static func fullNameFor( _ day: Self) -> String? {
        fullNameFor(day.rawValue)
    }
    
    static func shortNameFor(_ dayNumber: Int) -> String? {
        let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        guard 0..<days.count ~= dayNumber else { return nil }
        return days[dayNumber]
    }
    
    static func shortNameFor(_ day: Self) -> String? {
        shortNameFor(day.rawValue)
    }
    
    static func shortNamesFor(_ days: [Self]) -> String? {
        days.count == 7 ? "Каждый день" : days.compactMap { shortNameFor($0) }.joined(separator: ", ")
    }
    
    static func daysToBinary(_ days: [Self]) -> String {
        Self.allCases.map { days.contains($0) ? "1" : "0" }.joined()
    }
    
    static func binaryToDays(_ binaryString: String) -> [Self] {
        var days: [Self] = []
        binaryString.enumerated().forEach { if Int(String($1)) == 1 { days.append(Self.allCases[$0]) }  }
        return days
    }
    
    static var count: Int {
        Self.allCases.count
    }
}
