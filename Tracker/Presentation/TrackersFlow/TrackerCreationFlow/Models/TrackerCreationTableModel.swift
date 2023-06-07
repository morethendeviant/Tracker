//
//  TrackerCreationTableModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 03.04.2023.
//

import Foundation

struct HabitScreenContent {
    let daysAmount: Int?
    let trackerName: String?
    let categoryName: String?
    let scheduleText: String?
    let emoji: Int?
    let color: Int?
    let categoryCellName: String
    let scheduleCellName: String?
}

enum TrackerCreationTableModel {
    case habit(TrackerViewModel?)
    case event(TrackerViewModel?)
    
    func tableContent() -> HabitScreenContent {
        let categoryText = NSLocalizedString("category", comment: "Category")
        let scheduleText = NSLocalizedString("schedule", comment: "Schedule")
        
        switch self {
        case .habit(let tracker):
            return HabitScreenContent(daysAmount: tracker?.daysAmount,
                                      trackerName: tracker?.name,
                                      categoryName: tracker?.category,
                                      scheduleText: DayOfWeek.shortNamesFor(tracker?.schedule ?? []),
                                      emoji: tracker?.emoji,
                                      color: tracker?.color,
                                      categoryCellName: categoryText,
                                      scheduleCellName: scheduleText)
            
        case .event(let tracker):
            return HabitScreenContent(daysAmount: tracker?.daysAmount,
                                      trackerName: tracker?.name,
                                      categoryName: tracker?.category,
                                      scheduleText: nil,
                                      emoji: tracker?.emoji,
                                      color: tracker?.color,
                                      categoryCellName: categoryText,
                                      scheduleCellName: nil)
        }
    }
}
