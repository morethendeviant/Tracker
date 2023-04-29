//
//  EventCreationCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

protocol EventCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)? { get set }
    var finishFlowOnCreate: (() -> Void)? { get set }
}

final class EventCreationCoordinator: BaseCoordinator, Coordinatable, EventCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)?
    var finishFlowOnCreate: (() -> Void)?
    
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

// MARK: - Private Methods

private extension EventCreationCoordinator {
    func performFlow() {
        let eventModule = self.modulesFactory.makeEventCreationView()
        let eventView = eventModule.view
        let eventCoordination = eventModule.coordination
        
        eventCoordination.onCreate = { [weak self, weak eventView] in
            guard let self else { return }
            self.router.dismissModule(eventView)
            self.finishFlowOnCreate?()
        }

        eventCoordination.onCancel = { [weak self, weak eventView] in
            guard let self else { return }
            self.router.dismissModule(eventView)
            self.finishFlowOnCancel?()
        }
        
        eventCoordination.onHeadForCategory = { [weak self, weak eventCoordination] category in
            guard let self else { return }

            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router, selectedCategory: category)
            self.addDependency(categoryCoordinator)
            categoryCoordinator.finishFlow = { [weak categoryCoordinator] category in
                eventCoordination?.selectCategory(category)
                self.removeDependency(categoryCoordinator)
            }

            categoryCoordinator.startFlow()
        }

        self.router.present(eventView) { [weak self] in
            self?.finishFlowOnCancel?()
        }
    }
}
