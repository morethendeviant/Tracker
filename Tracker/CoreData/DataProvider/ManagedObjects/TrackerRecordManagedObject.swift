//
//  TrackerRecordManagedItem.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 13.04.2023.
//

import CoreData

@objc(TrackerRecordManagedObject)
final class TrackerRecordManagedObject: NSManagedObject {
    @NSManaged var iD: String
    @NSManaged var date: Date
    @NSManaged var tracker: TrackerManagedObject
}
