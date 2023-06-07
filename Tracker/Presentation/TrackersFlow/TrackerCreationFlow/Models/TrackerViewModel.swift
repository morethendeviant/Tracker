//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 06.06.2023.
//

import Foundation

struct TrackerViewModel {
    let id: String
    let name: String
    let category: String
    let schedule: [DayOfWeek]
    let color: Int
    let emoji: Int
    let daysAmount: Int
}
