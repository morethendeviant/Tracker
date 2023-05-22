//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

struct TrackerCategory: Hashable {
    let name: String
    let trackers: [Tracker]
    
    init(name: String, trackers: [Tracker] = []) {
        self.name = name
        self.trackers = trackers
    }
}
