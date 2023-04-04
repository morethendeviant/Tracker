//
//  TrackersContainer.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 04.04.2023.
//

import Foundation

final class TrackersCategorizedContainer {
    
    static let shared = TrackersCategorizedContainer()
    
    private(set) var categories: [TrackerCategory] =
    [TrackerCategory(name: "Домашний уют",
                     trackers: [Tracker(name: "Полить кота", color: 1, emoji: 2, schedule: [.mon, .tue])]),
     TrackerCategory(name: "Радостные мелочи",
                     trackers: [Tracker(name: "Поныть в пачке", color: 3, emoji: 4, schedule: [.fri, .sat]),
                                Tracker(name: "Погладить цветы", color: 4, emoji: 5, schedule: [.fri, .sun])])]
    
    func add(tracker: Tracker, forCategory name: String) {
        if let index = categories.firstIndex(where: { $0.name == name}) {
            let category = categories[index]
            var trackers = category.trackers
            trackers.append(tracker)
            categories[index] = TrackerCategory(name: category.name, trackers: trackers)
        } else {
            let trackerCategory = TrackerCategory(name: name, trackers: [tracker])
            categories.append(trackerCategory)
        }
    }
}
