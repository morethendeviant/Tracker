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
    case habit, event
    
    func defaultTableContent() -> [CellContent] {
        switch self {
        case .habit: return [CellContent(text: "Категория", detailText: nil) , CellContent(text: "Расписание", detailText: nil)]
        case .event: return [CellContent(text: "Категория", detailText: nil)]
        }
    }
}
