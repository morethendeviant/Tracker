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
        let categorySelectModule = modulesFactory.makeCategorySelectView(selectedCategory: selectedCategory)
        let categorySelectView = categorySelectModule.view
        let categorySelectCoordination = categorySelectModule.coordination
        
        categorySelectCoordination.onFinish = { [weak self, weak categorySelectView] category in
            guard let self else { return }
            self.router.dismissModule(categorySelectView)
            self.finishFlow?(category)
        }

        categorySelectCoordination.onHeadForCategoryCreation = { [weak self, weak categorySelectCoordination] in
            guard let self, let categorySelectCoordination else { return }
            let categoryCreateModule = self.modulesFactory.makeCategoryCreateView()
            let categoryCreateView = categoryCreateModule.view
            let categoryCreateCoordination = categoryCreateModule.coordination

            categoryCreateCoordination.onReturnWithDone = { [weak categoryCreateView] categoryName in
                categorySelectCoordination.setNewCategory(categoryName)
                self.router.dismissModule(categoryCreateView)
            }

            self.router.present(categoryCreateView)
        }
        
        categorySelectCoordination.headForAlert = { [weak self] alertModel in
            self?.router.presentActionSheet(alertModel: alertModel)
        }
        
        router.present(categorySelectView) { [weak self, weak categorySelectCoordination] in
            guard let categorySelectCoordination else { return }
            self?.finishFlow?(categorySelectCoordination.selectedCategory)
        }
    }
}
