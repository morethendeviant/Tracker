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
    var headForAlert: ((AlertModel) -> Void)? { get set }
    var selectedCategory: String? { get }
    
    func setNewCategory(_: String)
}

protocol CategoriesDataSourceProvider {
    var selectedCategory: String? { get }
}

protocol CategorySelectViewModelProtocol {
    var categories: [CategoryCellModel] { get }
    var categoriesObserver: Observable<[CategoryCellModel]> { get }
    
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
    var headForAlert: ((AlertModel) -> Void)?
    
    @Observable var categories: [CategoryCellModel] = []
    
    private var dataProvider: CategorySelectDataStoreProtocol
    private(set) var selectedCategory: String?
  
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
            let categoryNames = try dataProvider.fetchAllCategories().map { $0.name }
            categories = categoryNames.map {
                let isSelected = $0 == selectedCategory
                return CategoryCellModel(name: $0, isSelected: isSelected)
            }
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
}

// MARK: - View Model Protocol

extension CategorySelectViewModel: CategorySelectViewModelProtocol {
    var categoriesObserver: Observable<[CategoryCellModel]> {
        $categories
    }
    
    func viewDidLoad() {
        reloadCategories()
    }
    
    func addButtonTapped() {
        onHeadForCategoryCreation?()
    }
    
    func selectCategory(_ category: String?) {
        onFinish?(category)
    }
    
    func deleteCategoryAt(index: Int) {
        let alertText = NSLocalizedString("deleteAlertText", comment: "Text for delete alert")
        let alertDeleteActionText = NSLocalizedString("deleteActionText", comment: "Text for alert delete button")
        let alertCancelText = NSLocalizedString("cancelActionText", comment: "Text for alert cancel button")
        let alertDeleteAction = AlertAction(actionText: alertDeleteActionText, actionRole: .destructive, action: { [unowned self] in
            let category = TrackerCategory(name: categories[index].name)
            do {
                try dataProvider.deleteCategory(category)
                if selectedCategory == category.name { selectedCategory = nil }
                reloadCategories()
            } catch {
                handleError(message: error.localizedDescription)
            }
        })
        let alertCancelAction = AlertAction(actionText: alertCancelText, actionRole: .cancel, action: nil)
        let alertModel = AlertModel(alertText: alertText, alertActions: [alertDeleteAction, alertCancelAction])
        headForAlert?(alertModel)
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
