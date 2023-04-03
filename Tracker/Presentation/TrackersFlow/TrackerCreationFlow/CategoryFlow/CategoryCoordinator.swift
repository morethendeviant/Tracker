//
//  CategoryCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

protocol CategoryCoordinatorOutput {
    var finishFlow: ((Int?) -> Void)? { get set }
}

final class CategoryCoordinator: BaseCoordinator, Coordinatable, CategoryCoordinatorOutput {
    var finishFlow: ((Int?) -> Void)?
    
    private var coordinatorsFactory: CoordinatorsFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    private var selectedCategory: Int?
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable, selectedCategory: Int?) {
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
    func performFlow(selectedCategory: Int?) {
        let categorySelectView = modulesFactory.makeCategorySelectView(selectedCategory: selectedCategory)
        
        var categoryCoordinator = categorySelectView as? CategorySelectCoordinatorProtocol
        
        categoryCoordinator?.onFinish = { [weak self] category in
            self?.router.dismissModule(categorySelectView)
            self?.finishFlow?(category)
        }
        
        router.present(categorySelectView) { [weak self] in
            self?.finishFlow?(nil)
        }
    }
}
