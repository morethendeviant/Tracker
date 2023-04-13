//
//  DataStore.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 13.04.2023.
//

import Foundation
import CoreData


protocol TrackerStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: Tracker) throws
    func delete(_ record: NSManagedObject) throws
}

protocol TrackerCategoryStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ tracker: Tracker, for categoryName: String) throws
    func delete(_ record: NSManagedObject) throws
    func read() -> [TrackerCategory]
}

protocol TrackerRecordStore {
    func add(_ record: TrackerRecord) throws
    func read() throws -> Set<TrackerRecord>
    func delete(_ record: TrackerRecord) throws

}


final class DataStore {
    private let modelName = "TrackerCoreDataModel"

    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: modelName)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Код для обработки ошибки
                }
            })
            return container
        }()

    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    func delete(_ record: NSManagedObject) throws {
        context.delete(record)
        try context.save()
    }
}


//extension DataStore: TrackerStore {
//    var managedObjectContext: NSManagedObjectContext? {
//        context
//    }
//
//    func add(_ record: Tracker) throws {
//        let tracker = TrackerCoreData(context: context)
//        tracker.iD = record.id
//        tracker.color = Int16(record.color)
//        tracker.emoji = Int16(record.emoji)
//        tracker.name = record.name
//        tracker.schedule = DayOfWeek.daysToBinary(record.schedule)
//        try context.save()
//    }
//
//    func read(id: String) {//-> Tracker? {
//        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
//        request.returnsObjectsAsFaults = false
//        request.predicate = NSPredicate(format: " %K == %ld", #keyPath(TrackerCoreData.iD), id)
//        let trackers = try! context.fetch(request)
//        print(trackers)
//    }
//
//}

extension DataStore: TrackerCategoryStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
        
    func add(_ tracker: Tracker, for categoryName: String) throws {
        let trackerCoreData = TrackerManagedItem(context: context)
        trackerCoreData.iD = tracker.id
        trackerCoreData.color = Int16(tracker.color)
        trackerCoreData.emoji = Int16(tracker.emoji)
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = DayOfWeek.daysToBinary(tracker.schedule)
        
        
        if let category = read(name: categoryName) {
            category.addToTrackers(trackerCoreData)
            print("category created", category)
            try context.save()
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = categoryName
            newCategory.addToTrackers(trackerCoreData)
            print("category created", newCategory)
            try context.save()
        }
        
    }

    private func read(name: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: " %K == %@", #keyPath(TrackerCategoryCoreData.name), name)
        let trackerCategories = try! context.fetch(request)
        return trackerCategories.first
    }
    
    func read() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        let trackerCategories = try! context.fetch(request)
        print("trackerCategoriesCoreData", trackerCategories)
        
        let categories: [TrackerCategory?] = trackerCategories.map { categoryCoreData in
            guard let trackersCoreData = categoryCoreData.trackers as? Set<TrackerManagedItem> else { return nil }
            let trackers = trackersCoreData.map { trackerCoreData in
                Tracker(id: trackerCoreData.iD, 
                        name: trackerCoreData.name,
                        color: Int(trackerCoreData.color),
                        emoji: Int(trackerCoreData.emoji),
                        schedule: DayOfWeek.binaryToDays(trackerCoreData.schedule))
            }
            
            
            let category = TrackerCategory(name: categoryCoreData.name!, trackers: trackers)
            
            return category
        }
        print("categories", categories)
        
        return categories.compactMap { $0 }
    }
    
}

extension DataStore: TrackerRecordStore {
    func add(_ record: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordManagedItem(context: context)
        trackerRecordCoreData.iD = record.id
        trackerRecordCoreData.date = record.date
        try context.save()
    }
    
    func read() throws -> Set<TrackerRecord>  {
        let request = NSFetchRequest<TrackerRecordManagedItem>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        let trackerRecords = try! context.fetch(request)
        print("trackerrecords", trackerRecords)
        let set = Set(trackerRecords.map { recordCoreData in
            TrackerRecord(id: recordCoreData.iD, date: recordCoreData.date)
        })
        print("records set === ", set)
        return set
    }
    
    func delete(_ record: TrackerRecord) throws {
        
    }
    

    
}
