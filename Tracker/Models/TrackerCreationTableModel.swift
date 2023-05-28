//
//  TrackerCreationTableModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 03.04.2023.
//

import Foundation

struct CellContent {
    let text: String
    let detailText: String?
}

enum TrackerCreationTableModel {
    case habit
    case event
    
    func tableContent() -> [CellContent] {
        let categoryText = NSLocalizedString("category", comment: "Category")
        let scheduleText = NSLocalizedString("schedule", comment: "Schedule")
        switch self {
        case .habit: return [CellContent(text: categoryText, detailText: nil), CellContent(text: scheduleText, detailText: nil)]
        case .event: return [CellContent(text: categoryText, detailText: nil)]
        }
    }
}
