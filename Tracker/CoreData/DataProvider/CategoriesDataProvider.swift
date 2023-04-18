//
//  CategoryDataProvider.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 18.04.2023.
//

import Foundation
import CoreData

struct TrackersCategoryStoreUpdate {
    var insertedIndex: IndexPath?
    var updatedIndex: IndexPath?
    var deletedIndex: IndexPath?
}

protocol TrackerCategoriesDataProviderProtocol {
    var numberOfSections: Int { get }
    
    func numberOfItemsInSection(_ section: Int) -> Int
    func categoryName(at indexPath: IndexPath) -> String
    func addCategory(_ name: String)
    func deleteCategory(at indexPath: IndexPath)
}

final class TrackerCategoriesDataProvider: NSObject {
    weak var delegate: TrackerCategoryDataProviderDelegate?
    weak var errorHandlerDelegate: ErrorHandlerDelegate?

    private var insertedIndex: IndexPath?
    private var updatedIndex: IndexPath?
    private var deletedIndex: IndexPath?
    private var insertedSection: IndexSet?
    private var updatedSection: IndexSet?
    private var deletedSection: IndexSet?
    
    private let context: NSManagedObjectContext
    private let categoryDataStore: TrackerCategoryDataStoreProtocol = DataStore()
    
    private var fetchRequest = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryManagedObject> = {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: TrackerCategoryDataProviderDelegate, errorHandlerDelegate: ErrorHandlerDelegate? ) throws {
        self.delegate = delegate
        self.errorHandlerDelegate = errorHandlerDelegate
        self.context = Context.shared
    }
}

extension TrackerCategoriesDataProvider: TrackerCategoriesDataProviderProtocol {
    var numberOfSections: Int {
        1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func categoryName(at indexPath: IndexPath) -> String {
        let categoryManagedItem = fetchedResultsController.object(at: indexPath)
        return categoryManagedItem.name
    }
    
    func addCategory(_ name: String) {
        do {
            try categoryDataStore.addCategory(categoryName: name)
        } catch {
            errorHandlerDelegate?.handleError(message: error.localizedDescription)
        }
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let categoryManagedItem = fetchedResultsController.object(at: indexPath)
        do {
            try categoryDataStore.deleteCategory(categoryManagedItem)
        } catch {
            errorHandlerDelegate?.handleError(message: error.localizedDescription)
        }
    }
}

// MARK: - Fetch Results Controller Delegate

extension TrackerCategoriesDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackersCategoryStoreUpdate(
            insertedIndex: insertedIndex,
            updatedIndex: updatedIndex,
            deletedIndex: deletedIndex)
        )
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
