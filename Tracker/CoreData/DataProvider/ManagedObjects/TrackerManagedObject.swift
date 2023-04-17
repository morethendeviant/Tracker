//
//  TrackerManagedItem.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 13.04.2023.
//

import CoreData

@objc(TrackerManagedObject)
final class TrackerManagedObject: NSManagedObject {
    @NSManaged var iD: String
    @NSManaged var name: String
    @NSManaged var color: Int16
    @NSManaged var emoji: Int16
    @NSManaged var schedule: String
    @NSManaged var category: TrackerCategoryManagedObject
    @NSManaged var records: Set<TrackerRecordManagedObject>
    
    func addToRecords(_ record: TrackerRecordManagedObject) {
        records.insert(record)
    }
    
    func removeFromRecords(_ record: TrackerRecordManagedObject) {
        records.remove(record)
    }
}
