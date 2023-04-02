//
//  CategoryCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

protocol CategoryCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class CategoryCoordinator: BaseCoordinator, Coordinatable, CategoryCoordinatorOutput {
    var finishFlow: (() -> Void)?
    
    private var coordinatorsFactory: CoordinatorsFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
    }
    
    func startFlow() {
        performFlow()
    }
}

extension CategoryCoordinator {
    func performFlow() {
        let categorySelectView = modulesFactory.makeCategorySelectView()
        router.present(categorySelectView) { [weak self] in
            self?.finishFlow?()
        }
    }
}
