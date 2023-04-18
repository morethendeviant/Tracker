//
//  CategoryCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

protocol CategoryCoordinatorOutput {
    var finishFlow: ((String?) -> Void)? { get set }
}

final class CategoryCoordinator: BaseCoordinator, Coordinatable, CategoryCoordinatorOutput {
    var finishFlow: ((String?) -> Void)?
    
    private var coordinatorsFactory: CoordinatorsFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    private var selectedCategory: String?
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable, selectedCategory: String?) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
        self.selectedCategory = selectedCategory
    }
    
    func startFlow() {
        performFlow(selectedCategory: selectedCategory)
    }
}

extension CategoryCoordinator {
    func performFlow(selectedCategory: String?) {
        let categorySelectView = modulesFactory.makeCategorySelectView(selectedCategory: selectedCategory)
        let categorySelectCoordinator = categorySelectView as? CategorySelectCoordinatorProtocol
        
        categorySelectCoordinator?.onFinish = { [weak self, weak categorySelectView] category in
            guard let self else { return }
            self.router.dismissModule(categorySelectView)
            self.finishFlow?(category)
        }
        
        categorySelectCoordinator?.onHeadForCategoryCreation = { [weak self, weak categorySelectCoordinator] in
            guard let self else { return }
            let categoryCreateView = modulesFactory.makeCategoryCreateView()
            let categoryCreateCoordinator = categoryCreateView as? CategoryCreateCoordinatorProtocol
            
            categoryCreateCoordinator?.onReturnWithDone = { [weak categoryCreateView] categoryName in
                categorySelectCoordinator?.setNewCategory(categoryName)
                self.router.dismissModule(categoryCreateView)
            }

            self.router.present(categoryCreateView)
        }
        
        router.present(categorySelectView) { [weak self] in
            
            self?.finishFlow?(selectedCategory)
        }
    }
}
