//
//  Tracker.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

struct Tracker {
    private static var lastId: Int = 0
    
    let id: Int
    let name: String
    let color: Int
    let emoji: Int
    let schedule: [DayOfWeek]
    
    init(name: String, color: Int, emoji: Int, schedule: [DayOfWeek]) {
        Tracker.lastId += 1
        self.id = Tracker.lastId
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
