////
////  CategoryDataProvider.swift
////  Tracker
////
////  Created by Aleksandr Velikanov on 18.04.2023.
////
//
//import Foundation
//import CoreData
//
//protocol TrackerCategoriesDataProviderProtocol {
//    var categoriesAmount: Int { get }
//    
//    func addCategoryWith(name: String) throws
//    func fetchCategory(_ index: Int) -> String
//    func deleteCategoryAt(index: Int) throws
//}
//
//final class TrackerCategoriesDataProvider: NSObject {
//    //weak var delegate: TrackerCategoryDataProviderDelegate?
//
//    private var insertedIndex: IndexPath?
//    private var updatedIndex: IndexPath?
//    private var deletedIndex: IndexPath?
//    
//    private let context: NSManagedObjectContext
//    private let categoryDataStore: TrackerCategoryDataStoreProtocol = DataStore()
//    
//    private var fetchRequest = NSFetchRequest<TrackerCategoryManagedObject>(entityName: "TrackerCategoryCoreData")
//    
//    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryManagedObject> = {
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                                  managedObjectContext: context,
//                                                                  sectionNameKeyPath: nil,
//                                                                  cacheName: nil)
//        fetchedResultsController.delegate = self
//        try? fetchedResultsController.performFetch()
//        return fetchedResultsController
//    }()
//    
//    init() //delegate: TrackerCategoryDataProviderDelegate) {
//        //self.delegate = delegate
//        self.context = Context.shared
//    }
//}
//
//extension TrackerCategoriesDataProvider: TrackerCategoriesDataProviderProtocol {
//    func fetchCategory(_ index: Int) -> String {
//        let indexPath = IndexPath(row: index, section: 0)
//        return fetchedResultsController.object(at: indexPath).name
//    }
//    
//    var categoriesAmount: Int {
//        fetchedResultsController.sections?[0].numberOfObjects ?? 0
//    }
//    
//    func addCategoryWith(name: String) throws {
//        try categoryDataStore.addCategory(categoryName: name)
//    }
//    
//    func deleteCategoryAt(index: Int) throws {
//        let indexPath = IndexPath(row: index, section: 0)
//        let categoryManagedItem = fetchedResultsController.object(at: indexPath)
//        try categoryDataStore.deleteCategory(categoryManagedItem)
//    }
//}
//
////// MARK: - Fetch Results Controller Delegate
////
////extension TrackerCategoriesDataProvider: NSFetchedResultsControllerDelegate {
////    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////        delegate?.didUpdate(TrackersCategoryStoreUpdate(
////            insertedIndex: insertedIndex,
////            updatedIndex: updatedIndex,
////            deletedIndex: deletedIndex)
////        )
////        insertedIndex = nil
////        updatedIndex = nil
////        deletedIndex = nil
////    }
////
////    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
////        switch type {
////        case .delete: deletedIndex = indexPath
////        case .update: updatedIndex = indexPath
////        case .insert: insertedIndex = newIndexPath
////        default: break
////        }
////    }
////}
