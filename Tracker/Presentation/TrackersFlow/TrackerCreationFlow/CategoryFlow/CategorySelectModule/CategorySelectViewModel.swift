//
//  CategorySelectViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 22.04.2023.
//

import Foundation

protocol CategorySelectCoordination: AnyObject {
    var onHeadForCategoryCreation: (() -> Void)? { get set }
    var onFinish: ((String?) -> Void)? { get set }
    var headForError: ((String) -> Void)? { get set }
    
    func setNewCategory(_: String)
}

protocol CategorySelectViewModelProtocol {
    var categories: [String] { get }
    var categoriesObserver: Observable<[String]> { get }

    func viewDidLoad()
    func addButtonTapped()
    func selectCategory(_ category: String)
    func deleteCategoryAt(index: Int)
}

final class CategorySelectViewModel {
    var onHeadForCategoryCreation: (() -> Void)?
    var onFinish: ((String?) -> Void)?
    var headForError: ((String) -> Void)?
    
    private var dataProvider: TrackerCategoryDataStoreProtocol = DataStore()
    
    @Observable var categories: [String]
    
    init() {
        self.dataProvider = DataStore()
        self.categories = dataProvider.fetchAllCategories()
    }
}

// MARK: - Private Methods

private extension CategorySelectViewModel {
    func reloadCategories() {
        categories = dataProvider.fetchAllCategories()
    }
}

// MARK: - View Model Protocol

extension CategorySelectViewModel: CategorySelectViewModelProtocol {
    var categoriesObserver: Observable<[String]> {
        $categories
    }
    
    func viewDidLoad() {
        reloadCategories()
    }
    
    func addButtonTapped() {
        onHeadForCategoryCreation?()
    }
    
    func selectCategory(_ category: String) {
        onFinish?(category)
    }
    
    func deleteCategoryAt(index: Int) {
        do {
            try dataProvider.deleteCategoryWith(name: categories[index])
            reloadCategories()
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
}

// MARK: - Coordination

extension CategorySelectViewModel: CategorySelectCoordination {
    func setNewCategory(_ name: String) {
        do {
            try dataProvider.addCategory(categoryName: name)
            reloadCategories()
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
