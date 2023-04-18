//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 14.04.2023.
//

import Foundation
import CoreData

struct TrackersStoreUpdate {
    var insertedSection: IndexSet?
    var updatedSection: IndexSet?
    var deletedSection: IndexSet?
    var insertedIndex: IndexPath?
    var updatedIndex: IndexPath?
    var deletedIndex: IndexPath?
}

protocol TrackersDataProviderProtocol {
    var numberOfSections: Int { get }
    
    func numberOfItemsInSection(_ section: Int) -> Int
    func sectionName(_ section: Int) -> String?
    
    func tracker(at indexPath: IndexPath) -> Tracker?
    func getTrackers(name: String?, weekday: DayOfWeek?)
    func deleteTracker(at indexPath: IndexPath)
    
    func addRecord(at indexPath: IndexPath, for date: Date)
    func deleteRecord(at indexPath: IndexPath, for date: Date)
    func checkRecord(at indexPath: IndexPath, for date: Date) -> Bool
    func recordsAmount(at indexPath: IndexPath) -> Int
}

final class TrackersDataProvider: NSObject {
    weak var delegate: TrackerDataProviderDelegate?
    weak var errorHandlerDelegate: ErrorHandlerDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerDataStore: TrackerDataStoreProtocol = DataStore()
    private let trackerRecordDataStore: TrackerRecordDataStoreProtocol = DataStore()
    
    private var insertedIndex: IndexPath?
    private var updatedIndex: IndexPath?
    private var deletedIndex: IndexPath?
    private var insertedSection: IndexSet?
    private var updatedSection: IndexSet?
    private var deletedSection: IndexSet?
    
    private var fetchRequest = NSFetchRequest<TrackerManagedObject>(entityName: "TrackerCoreData")
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerManagedObject> = {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: #keyPath(TrackerManagedObject.category.name),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(weekday: DayOfWeek, delegate: TrackerDataProviderDelegate, errorHandlerDelegate: ErrorHandlerDelegate? ) throws {
        fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerManagedObject.schedule), DayOfWeek.dayToBinary(weekday))
        self.delegate = delegate
        self.errorHandlerDelegate = errorHandlerDelegate
        self.context = Context.shared
    }
}

// MARK: - Data Provider

extension TrackersDataProvider: TrackersDataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func sectionName(_ section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func getTrackers(name: String? = nil, weekday: DayOfWeek? = nil) {
        var compoundPredicateSubpredicates: [NSPredicate] = []
        
        if let name, !name.isEmpty {
            let predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerManagedObject.name), name)
            compoundPredicateSubpredicates.append(predicate)
        }
        
        if let weekday {
            let predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerManagedObject.schedule), DayOfWeek.dayToBinary(weekday))
            compoundPredicateSubpredicates.append(predicate)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: compoundPredicateSubpredicates)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            errorHandlerDelegate?.handleError(message: error.localizedDescription)
        }
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerManagedItem = fetchedResultsController.object(at: indexPath)
        return Tracker(managedItem: trackerManagedItem)
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            try trackerDataStore.delete(tracker)
        } catch {
            errorHandlerDelegate?.handleError(message: error.localizedDescription)
        }
    }
    
    func addRecord(at indexPath: IndexPath, for date: Date) {
        let trackerObject = fetchedResultsController.object(at: indexPath)
        do {
            try trackerRecordDataStore.addRecord(trackerObject: trackerObject, date: date )
        } catch {
            errorHandlerDelegate?.handleError(message: error.localizedDescription)
        }
    }
    
    func deleteRecord(at indexPath: IndexPath, for date: Date) {
        let trackerObject = fetchedResultsController.object(at: indexPath)
        do {
            try trackerRecordDataStore.deleteRecord(trackerObject.id, date: date)
        } catch {
            errorHandlerDelegate?.handleError(message: error.localizedDescription)
        }
    }
    
    func checkRecord(at indexPath: IndexPath, for date: Date) -> Bool {
        let trackerObject = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordDataStore.getRecord(trackerObject.id, date: date) != nil
        } catch {
            errorHandlerDelegate?.handleError(message: error.localizedDescription)
            return false
        }
    }
    
    func recordsAmount(at indexPath: IndexPath) -> Int {
        let tracker = fetchedResultsController.object(at: indexPath)
        return tracker.records.count
    }
}

// MARK: - Fetch Results Controller Delegate

extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackersStoreUpdate(
            insertedSection: insertedSection,
            updatedSection: updatedSection,
            deletedSection: deletedSection,
            insertedIndex: insertedIndex,
            updatedIndex: updatedIndex,
            deletedIndex: deletedIndex)
        )
        insertedSection = nil
        updatedSection = nil
        deletedSection = nil
        insertedIndex = nil
        updatedIndex = nil
        deletedIndex = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: insertedSection = IndexSet(integer: sectionIndex)
        case .update: updatedSection = IndexSet(integer: sectionIndex)
        case .delete: deletedSection = IndexSet(integer: sectionIndex)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete: deletedIndex = indexPath
        case .update: updatedIndex = indexPath
        case .insert: insertedIndex = newIndexPath
        default: break
        }
    }
}
