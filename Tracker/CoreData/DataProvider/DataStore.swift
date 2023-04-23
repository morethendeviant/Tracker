//
//  DataStore.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 16.04.2023.
//

import Foundation
import CoreData

protocol TrackerCategoryDataStoreProtocol {
    func addCategory(categoryName: String) throws -> TrackerCategoryManagedObject
    func fetchCategoryFor(name: String) throws -> TrackerCategoryManagedObject?
    func deleteCategory(_ category: TrackerCategoryManagedObject) throws
    func deleteCategoryWith(name: String) throws
    func fetchAllCategories() -> [String]
}

protocol TrackerDataStoreProtocol {
    func add(_ tracker: Tracker, for categoryName: String) throws
    func delete(_ tracker: TrackerManagedObject) throws
}

protocol TrackerRecordDataStoreProtocol {
    func addRecord(trackerObject: TrackerManagedObject, date: Date) throws
    func deleteRecord(_ id: String, date: Date) throws
    func getRecord(_ id: String, date: Date) throws -> TrackerRecordManagedObject?
}

// MARK: - Data Store

final class DataStore {
    let context = Context.shared
}

// MARK: - Category Data Store

extension DataStore: TrackerDataStoreProtocol {
    @discardableResult
    func addCategory(categoryName: String) throws -> TrackerCategoryManagedObject {
        let categoryObject = TrackerCategoryManagedObject(context: context)
        categoryObject.name = categoryName
        categoryObject.trackers = []
        try context.save()
        return categoryObject
    }
    
    func fetchAllCategories() -> [String] {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        guard let trackerCategories = try? context.fetch(request) else { return [] }
        return trackerCategories.map { $0.name }
    }
    
    private func getOrCreateCategoryFor(name: String) throws -> TrackerCategoryManagedObject {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: " %K == %@", #keyPath(TrackerCategoryManagedObject.name), name)
        let trackerCategories = try? context.fetch(request)
        if let category = trackerCategories?.first {
            return category
        } else {
            return try addCategory(categoryName: name)
        }
    }
    
    func fetchCategoryFor(name: String) throws -> TrackerCategoryManagedObject? {
        let request = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: " %K == %@", #keyPath(TrackerCategoryManagedObject.name), name)
        return try context.fetch(request).first
    }
    
    func deleteCategoryWith(name: String) throws {
        guard let category = try? fetchCategoryFor(name: name) else { return }
        try deleteCategory(category)
    }
    
    func deleteCategory(_ category: TrackerCategoryManagedObject) throws {
        context.delete(category)
        try context.save()
    }
}

// MARK: - Tracker Data Store

extension DataStore: TrackerCategoryDataStoreProtocol {
    func add(_ tracker: Tracker, for categoryName: String) throws {
        let trackerObject = TrackerManagedObject(context: context)
        trackerObject.setFrom(tracker: tracker)
        let category = try getOrCreateCategoryFor(name: categoryName)
        trackerObject.category = category
        category.addToTrackers(trackerObject)
        try context.save()
    }
    
    func delete(_ tracker: TrackerManagedObject) throws {
        let category = tracker.category
        tracker.records.forEach { context.delete($0) }
        
        context.delete(tracker)
        try context.save()
        if let categoryObject = try fetchCategoryFor(name: category.name), categoryObject.trackers.isEmpty {
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
    
    func deleteRecord(_ id: String, date: Date) throws {
        guard let record = try getRecord(id, date: date) else { return }
        context.delete(record)
        try context.save()
    }
    
    func getRecord(_ id: String, date: Date) throws -> TrackerRecordManagedObject? {
        let request = NSFetchRequest<TrackerRecordManagedObject>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        var compoundPredicate: [NSPredicate] = []
        compoundPredicate.append(NSPredicate(format: "%K == %@", #keyPath(TrackerRecordManagedObject.id), id))
        compoundPredicate.append(NSPredicate(format: "%K == %@", #keyPath(TrackerRecordManagedObject.date), date as CVarArg))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: compoundPredicate)
        let record = try context.fetch(request).first
        return record
    }
}
