//
//  DataStore.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 16.04.2023.
//

import Foundation
import CoreData

protocol DataStoreProtocol {
    func createCategory(_ categoryName: String) throws -> TrackerCategoryManagedObject
    func fetchAllCategories(date: String?) throws -> [TrackerCategory]
    func deleteCategory(_ category: TrackerCategory) throws
    func createTracker(_ tracker: Tracker, categoryName: String) throws
    func deleteTracker(_ tracker: Tracker) throws
    func createRecord(_ record: TrackerRecord) throws
    func getRecord(_ record: TrackerRecord) throws -> TrackerRecordManagedObject?
    func deleteRecord(_ record: TrackerRecord) throws
    func readRecordAmountWith(id: String) throws -> Int
    func checkForExistence(_ record: TrackerRecord) throws -> Bool
}

// MARK: - Data Store

final class DataStore {
    let context = Context.shared
}

extension DataStore: DataStoreProtocol {
    @discardableResult
    func createCategory(_ categoryName: String) throws -> TrackerCategoryManagedObject {
        let categoryObject = TrackerCategoryManagedObject(context: context)
        categoryObject.name = categoryName
        categoryObject.trackers = []
        try context.save()
        return categoryObject
    }
    
    // --------
    func fetchAllCategories(date: String?) throws -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        if let date {
            request.predicate = NSPredicate(format: "ANY %K CONTAINS[n] %@", #keyPath(TrackerCategoryManagedObject.trackers.schedule), date as CVarArg)
        }
        
        let trackerCategoryObjects = try context.fetch(request)
        
        let trackerCategories = trackerCategoryObjects.map {
            let trackers = $0.trackers.map { Tracker(managedItem: $0) }
            return TrackerCategory(name: $0.name, trackers: trackers)}
        return trackerCategories
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryManagedObject.name), category.name)
        guard let trackerCategoryObjects = try? context.fetch(request),
              let trackerCategoryObject = trackerCategoryObjects.first
        else {
            return
        }
        context.delete(trackerCategoryObject)
        try context.save()
    }

    // --------
    
    func createTracker(_ tracker: Tracker, categoryName: String) throws {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryManagedObject.name), categoryName)
        
        let trackerCategoryObjects = try? context.fetch(request)
        if let trackerCategoryObject = trackerCategoryObjects?.first { // TODO: refactor!
            let trackerObject = TrackerManagedObject(context: context)
            trackerObject.setFrom(tracker: tracker)
            trackerObject.category = trackerCategoryObject
            trackerCategoryObject.addToTrackers(trackerObject)
        }
        else {
            let trackerObject = TrackerManagedObject(context: context)
            let trackerCategoryObject = try createCategory(categoryName)
            trackerObject.setFrom(tracker: tracker)
            trackerObject.category = trackerCategoryObject
            trackerCategoryObject.addToTrackers(trackerObject)
        }
        try context.save()
    }
    
    //--------
    private func getTracker(_ id: String) throws -> TrackerManagedObject? {
        let request = NSFetchRequest<TrackerManagedObject>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerManagedObject.id), id)
        let trackerObjects = try context.fetch(request)
        return trackerObjects.first
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let trackerCategoryObject = try getTracker(tracker.id) else { return }
        context.delete(trackerCategoryObject)
        try context.save()
    }
    
    func createRecord(_ record: TrackerRecord) throws {
        guard let trackerObject = try getTracker(record.id) else { return }

        let recordObject = TrackerRecordManagedObject(context: context)
        recordObject.id = record.id
        recordObject.date = record.date
        recordObject.tracker = trackerObject
        trackerObject.addToRecords(recordObject)
        try context.save()
    }
    
    func getRecord(_ record: TrackerRecord) throws -> TrackerRecordManagedObject? {
        let request = NSFetchRequest<TrackerRecordManagedObject>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        var compoundPredicate: [NSPredicate] = []
        compoundPredicate.append(NSPredicate(format: "%K == %@", #keyPath(TrackerRecordManagedObject.id), record.id))
        compoundPredicate.append(NSPredicate(format: "%K == %@", #keyPath(TrackerRecordManagedObject.date), record.date as CVarArg))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: compoundPredicate)
        let record = try context.fetch(request).first
        print("record", record)
        return record
    }
        
    func deleteRecord(_ record: TrackerRecord) throws {
        guard let record = try getRecord(record) else { return }
        
        record.tracker.removeFromRecords(record)
        context.delete(record)

        try context.save()
    }
    
    func readRecordAmountWith(id: String) throws -> Int {
        try getTracker(id)?.records.count ?? 0
    }
    
    func checkForExistence(_ record: TrackerRecord) throws -> Bool {
        try getRecord(record) != nil
        
    }
}
