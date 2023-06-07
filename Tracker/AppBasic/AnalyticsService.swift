//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 03.06.2023.
//

import YandexMobileMetrica

struct AnalyticsService {        
    func reportEvent(event: Event, screen: Screen, item: Item? = nil) {
        var params: [AnyHashable: Any] = ["screen": screen.rawValue]
        if event == .tap, let item {
            params["item"] = item.rawValue
        }
        
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        
        print(event.rawValue, item?.rawValue ?? "", ", on screen", screen.rawValue)
    }
}

enum Event: String {
    case open, close, tap
}

enum Screen: String {
    case trackersList = "trackers_list"
}

enum Item: String {
    case addTracker = "add_tracker"
    case trackerChecked = "tracker_checked"
    case filter, edit, delete
}
