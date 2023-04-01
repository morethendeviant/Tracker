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
        let formatter = DateFormatter()
        return DayOfWeek.allCases[ Calendar.current.component(.weekday, from: self) - 1 ]
        
        
    }
}
