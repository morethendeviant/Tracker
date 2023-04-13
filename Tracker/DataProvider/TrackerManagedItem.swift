//
//  TrackerManagedItem.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 13.04.2023.
//

import CoreData

@objc(TrackerManagedItem)
public class TrackerManagedItem: NSManagedObject {
    @NSManaged var iD: String
    @NSManaged var name: String
    @NSManaged var color: Int16
    @NSManaged var emoji: Int16
    @NSManaged var schedule: String
}
