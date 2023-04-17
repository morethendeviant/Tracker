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

private extension EventCreationCoordinator {
    func performFlow() {
        let eventView = self.modulesFactory.makeEventCreationView()
        let eventCoordinator = eventView as? EventCreationCoordinatorProtocol
        
        eventCoordinator?.onCreate = { [weak self, weak eventView] in
            guard let self else { return }
            self.router.dismissModule(eventView)
            self.finishFlowOnCreate?()
        }

        eventCoordinator?.onCancel = { [weak self, weak eventView] in
            guard let self else { return }
            self.router.dismissModule(eventView)
            self.finishFlowOnCancel?()
        }
        
        eventCoordinator?.onHeadForCategory = { [weak self, weak eventCoordinator] category in
            guard let self else { return }

            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router, selectedCategory: category)
            self.addDependency(categoryCoordinator)
            categoryCoordinator.finishFlow = { [weak categoryCoordinator] category in
                eventCoordinator?.selectCategory(category)
                self.removeDependency(categoryCoordinator)
            }

            categoryCoordinator.startFlow()
        }

        self.router.present(eventView) { [weak self] in
            self?.finishFlowOnCancel?()
        }
    }
}
