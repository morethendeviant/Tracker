//
//  FilterModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 04.06.2023.
//

import Foundation

enum Filter {
    case all
    case today
    case finished
    case unfinished
    
    var description: String {
        switch self {
        case .all: return NSLocalizedString("allFilters", comment: "All filter text")
        case .today: return NSLocalizedString("todayFilters", comment: "Today filter text")
        case .finished: return NSLocalizedString("finishedFilters", comment: "Finished filter text")
        case .unfinished: return NSLocalizedString("unfinishedFilters", comment: "Unfinished filter text")
        }
    }
}
