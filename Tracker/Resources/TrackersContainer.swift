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
                     trackers: [Tracker(name: "Полить кота", color: 1, emoji: 2, schedule: [.mon, .tue]),
                                Tracker(name: "Полить кота", color: 1, emoji: 2, schedule: [.mon, .tue])]),
     TrackerCategory(name: "Радостные мелочи",
                     trackers: [Tracker(name: "Сдать задание", color: 2, emoji: 1, schedule: [.tue, .sat]),
                                Tracker(name: "Погладить цветы", color: 3, emoji: 5, schedule: [.mon, .sat])]),
     TrackerCategory(name: "Нерадостные мелочи",
                     trackers: [Tracker(name: "Поныть в пачке", color: 4, emoji: 7, schedule: [.tue, .sat])]),
     TrackerCategory(name: "Рабочие заботы",
                      trackers: [Tracker(name: "Поговорить у кулера", color: 5, emoji: 9, schedule: [.mon, .tue])])
    ]
    
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
