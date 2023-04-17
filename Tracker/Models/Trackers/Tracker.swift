//
//  Tracker.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

struct Tracker {
    let id: String
    let name: String
    let color: Int
    let emoji: Int
    let schedule: [DayOfWeek]
    
    init(id: String = UUID().uuidString, name: String, color: Int, emoji: Int, schedule: [DayOfWeek]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}

extension Tracker {
    init(managedItem: TrackerManagedObject) {
        self.id = managedItem.iD
        self.name = managedItem.name
        self.color = Int(managedItem.color)
        self.emoji = Int(managedItem.emoji)
        self.schedule = DayOfWeek.numbersToDays(managedItem.schedule)
    }
}
