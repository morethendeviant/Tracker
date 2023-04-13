//
//  TrackerRecordManagedItem.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 13.04.2023.
//

import CoreData

@objc(TrackerRecordManagedItem)
public class TrackerRecordManagedItem: NSManagedObject {
    @NSManaged var iD: String
    @NSManaged var date: Date
}
