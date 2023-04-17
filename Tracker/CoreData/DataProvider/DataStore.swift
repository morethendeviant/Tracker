//
//  DataStore.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 16.04.2023.
//

import Foundation
import CoreData

protocol TrackerDataStoreProtocol {
    func add(_ tracker: Tracker, for categoryName: String) throws
    func delete(_ tracker: TrackerManagedObject) throws
}

protocol TrackerRecordDataStoreProtocol {
    func addRecord(trackerObject: TrackerManagedObject, date: Date) throws
    func deleteRecord(_ id: String, date: Date?) throws
    func getRecord(_ id: String, date: Date?) throws -> TrackerRecordManagedObject?
}

// MARK: - Data Store

final class DataStore {
    let context = Context.shared
}

// MARK: - Category Data Store

extension DataStore {
    private func getCategoryFor(name: String, storing tracker: TrackerManagedObject) -> TrackerCategoryManagedObject {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: " %K == %@", #keyPath(TrackerCategoryManagedObject.name), name)
        let trackerCategories = try? context.fetch(request)
        guard let category = trackerCategories?.first else {
            let newCategory = TrackerCategoryManagedObject(context: context)
            newCategory.name = name
            newCategory.addToTrackers(tracker)
            return newCategory
        }
        category.addToTrackers(tracker)
        return category
    }
    
    private func getCategoryFor(name: String) throws -> TrackerCategoryManagedObject? {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: " %K == %@", #keyPath(TrackerCategoryManagedObject.name), name)
        return try context.fetch(request).first
    }
    
    private func deleteCategory(_ category: TrackerCategoryManagedObject) throws {
        context.delete(category)
        try context.save()
    }
}

// MARK: - Tracker Data Store

extension DataStore: TrackerDataStoreProtocol {
    func add(_ tracker: Tracker, for categoryName: String) throws {
        let trackerObject = TrackerManagedObject(context: context)
        trackerObject.id = tracker.id
        trackerObject.color = Int16(tracker.color)
        trackerObject.emoji = Int16(tracker.emoji)
        trackerObject.name = tracker.name
        trackerObject.schedule = DayOfWeek.daysToNumbers(tracker.schedule)
        trackerObject.category = getCategoryFor(name: categoryName, storing: trackerObject)
        trackerObject.records = []
        try context.save()
    }
    
    func delete(_ tracker: TrackerManagedObject) throws {
        let category = tracker.category
        tracker.records.forEach { record in
            context.delete(record)
        }
        
        context.delete(tracker)
        try context.save()
        if let categoryObject = try getCategoryFor(name: category.name), categoryObject.trackers.isEmpty {
            try deleteCategory(categoryObject)
        }
    }
}

// MARK: - Record Data Store

extension DataStore: TrackerRecordDataStoreProtocol {
    func addRecord(trackerObject: TrackerManagedObject, date: Date) throws {
        let recordObject = TrackerRecordManagedObject(context: context)
        recordObject.id = trackerObject.id
        recordObject.date = date
        recordObject.tracker = trackerObject
        trackerObject.addToRecords(recordObject)
        try context.save()
    }
    
    func deleteRecord(_ id: String, date: Date? = nil) throws {
        guard let record = try getRecord(id, date: date) else { return }
        context.delete(record)
        try context.save()
    }
    
    func getRecord(_ id: String, date: Date?) throws -> TrackerRecordManagedObject? {
        let request = NSFetchRequest<TrackerRecordManagedObject>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        var compoundPredicate: [NSPredicate] = []
        compoundPredicate.append(NSPredicate(format: "%K == %@", #keyPath(TrackerRecordManagedObject.id), id))
        if let date {
            compoundPredicate.append(NSPredicate(format: "%K == %@", #keyPath(TrackerRecordManagedObject.date), date as CVarArg))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: compoundPredicate)
        let record = try context.fetch(request).first
        return record
    }
}
