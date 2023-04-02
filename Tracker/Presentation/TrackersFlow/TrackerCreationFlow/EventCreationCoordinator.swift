//
//  EventCreationCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

protocol EventCreationCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class EventCreationCoordinator: BaseCoordinator, Coordinatable, EventCreationCoordinatorOutput {
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

private extension EventCreationCoordinator {
    func performFlow() {
        let eventView = self.modulesFactory.makeEventCreationView()
        var eventCoordinator = eventView as? EventCreationCoordinatorProtocol
        
        eventCoordinator?.onCancel = { [weak self] in
            self?.router.dismissModule(eventView)
            self?.finishFlow?()
        }
        
        eventCoordinator?.onHeadForCategory = { [weak self] in
            guard let self = self else { return }
            
            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router)
            self.addDependency(categoryCoordinator)
            categoryCoordinator.finishFlow = { [weak categoryCoordinator] in
                self.removeDependency(categoryCoordinator)
            }
            
            categoryCoordinator.startFlow()
        }

        self.router.present(eventView) { [weak self] in
            self?.finishFlow?()
        }
    }
}
