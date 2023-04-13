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
