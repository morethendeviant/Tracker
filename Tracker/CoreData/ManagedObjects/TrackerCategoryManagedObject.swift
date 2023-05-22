//
//  TrackerCategoryManagedItem.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 14.04.2023.
//

import CoreData

@objc(TrackerCategoryManagedObject)
final class TrackerCategoryManagedObject: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var trackers: Set<TrackerManagedObject>
    
    func addToTrackers(_ tracker: TrackerManagedObject) {
        trackers.insert(tracker)
    }
    
    func removeFromTrackers(_ tracker: TrackerManagedObject) {
        trackers.remove(tracker)
    }
}
