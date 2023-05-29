//
//  Tracker.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

struct Tracker: Hashable {
    let id: String
    let name: String
    let color: Int
    let emoji: Int
    let schedule: [DayOfWeek]
    let isPinned: Bool
    
    init(id: String = UUID().uuidString, name: String, color: Int, emoji: Int, schedule: [DayOfWeek], isPinned: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned
    }
}

extension Tracker {
    init(managedItem: TrackerManagedObject) {
        self.id = managedItem.id
        self.name = managedItem.name
        self.color = Int(managedItem.color)
        self.emoji = Int(managedItem.emoji)
        self.schedule = DayOfWeek.numbersToDays(managedItem.schedule)
        self.isPinned = managedItem.isPinned
    }
}
