//
//  CategorySelectViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 22.04.2023.
//

import Foundation

struct TrackersCategoryStoreUpdate {
    var insertedIndex: IndexPath?
    var updatedIndex: IndexPath?
    var deletedIndex: IndexPath?
}

protocol CategorySelectCoordination: AnyObject {
    var onHeadForCategoryCreation: (() -> Void)? { get set }
    var onFinish: ((String?) -> Void)? { get set }
    var headForError: ((String) -> Void)? { get set }
    
    func setNewCategory(_: String)
}

protocol CategorySelectViewModelProtocol {
    var categoriesAmount: Int { get }
    var categoriesUpdate: TrackersCategoryStoreUpdate? { get }
    var categoriesUpdateObserver: Observable<TrackersCategoryStoreUpdate?> { get }
    
    func categoryAt(index: Int) -> String
    func addButtonTapped()
    func selectCategory(_ category: String)
    func deleteCategoryAt(index: Int)
}

final class CategorySelectViewModel {
    var onHeadForCategoryCreation: (() -> Void)?
    var onFinish: ((String?) -> Void)?
    var headForError: ((String) -> Void)?
    
    private lazy var dataProvider: TrackerCategoriesDataProviderProtocol = TrackerCategoriesDataProvider(delegate: self)
    
    @Observable var categoriesUpdate: TrackersCategoryStoreUpdate?
}

// MARK: - View Model Protocol

extension CategorySelectViewModel: CategorySelectViewModelProtocol {
    var categoriesUpdateObserver: Observable<TrackersCategoryStoreUpdate?> {
        $categoriesUpdate
    }
    
    var categoriesAmount: Int {
        dataProvider.categoriesAmount
    }
    
    func categoryAt(index: Int) -> String {
        dataProvider.fetchCategory(index)
    }
    
    func addButtonTapped() {
        onHeadForCategoryCreation?()
    }
    
    func selectCategory(_ category: String) {
        onFinish?(category)
    }
    
    func deleteCategoryAt(index: Int) {
        do {
            try dataProvider.deleteCategoryAt(index: index)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
}

// MARK: - Coordination

extension CategorySelectViewModel: CategorySelectCoordination {
    func setNewCategory(_ name: String) {
        do {
            try dataProvider.addCategoryWith(name: name)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
}

// MARK: - Error Handling

extension CategorySelectViewModel: ErrorHandlerDelegate {
    func handleError(message: String) {
        headForError?(message)
    }
}

// MARK: - Data Provider Delegate

extension CategorySelectViewModel: TrackerCategoryDataProviderDelegate {
    func didUpdate(_ update: TrackersCategoryStoreUpdate) {
        categoriesUpdate = update
    }
}
