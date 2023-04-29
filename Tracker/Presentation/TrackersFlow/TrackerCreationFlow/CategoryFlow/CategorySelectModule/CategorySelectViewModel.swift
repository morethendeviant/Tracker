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
    var selectedCategory: String? { get }
    
    func setNewCategory(_: String)
}

protocol CategoriesDataSourceProvider {
    var selectedCategory: String? { get }
}

protocol CategorySelectViewModelProtocol {
    var categories: [String] { get }
    var categoriesObserver: Observable<[String]> { get }
    
    var selectedCategory: String? { get }

    func viewDidLoad()
    func addButtonTapped()
    func selectCategory(_ category: String?)
    func deleteCategoryAt(index: Int)
}

final class CategorySelectViewModel: CategoriesDataSourceProvider {
    var onHeadForCategoryCreation: (() -> Void)?
    var onFinish: ((String?) -> Void)?
    var headForError: ((String) -> Void)?
    
    private var dataProvider: CategorySelectDataStoreProtocol
    private(set) var selectedCategory: String?

    @Observable var categories: [String] = []
    
    init(dataProvider: CategorySelectDataStoreProtocol, selectedCategory: String?) {
        self.dataProvider = dataProvider
        self.selectedCategory = selectedCategory
        reloadCategories()
    }
}

// MARK: - Private Methods

private extension CategorySelectViewModel {
    func reloadCategories() {
        do {
            categories = try dataProvider.fetchAllCategories().map { $0.name }
        } catch {
            handleError(message: error.localizedDescription)
        }
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
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
        onFinish?(selectedCategory)
    }
    
    func deleteCategoryAt(index: Int) {
        let category = TrackerCategory(name: categories[index])
        do {
            try dataProvider.deleteCategory(category)
            reloadCategories()
            selectedCategory = nil
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
}

// MARK: - Coordination

extension CategorySelectViewModel: CategorySelectCoordination {
    func setNewCategory(_ name: String) {
        do {
            try dataProvider.createCategory(name)
            selectedCategory = name
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
