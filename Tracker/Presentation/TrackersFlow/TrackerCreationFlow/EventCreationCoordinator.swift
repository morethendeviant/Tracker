//
//  EventCreationCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

protocol EventCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)? { get set }
    var finishFlowOnConfirm: (() -> Void)? { get set }
    var finishFlowOnEdit: (() -> Void)? { get set }
}

final class EventCreationCoordinator: BaseCoordinator, Coordinatable, EventCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)?
    var finishFlowOnConfirm: (() -> Void)?
    var finishFlowOnEdit: (() -> Void)?

    private var coordinatorsFactory: CoordinatorsFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    private var tracker: TrackerViewModel?
    private var screenAppearance: HabitScreenAppearance
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol,
         modulesFactory: ModulesFactoryProtocol,
         router: Routable,
         tracker: TrackerViewModel?,
         screenAppearance: HabitScreenAppearance) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
        self.tracker = tracker
        self.screenAppearance = screenAppearance
    }
    
    func startFlow() {
        performFlow()
    }
}

// MARK: - Private Methods

private extension EventCreationCoordinator {
    func performFlow() {
        let eventModule = self.modulesFactory.makeEventCreationView(tableDataModel: tracker,
                                                                    screenAppearance: screenAppearance)
        let eventView = eventModule.view
        let eventCoordination = eventModule.coordination
        
        eventCoordination.onCreate = { [weak self, weak eventView] in
            guard let self else { return }
            self.router.dismissModule(eventView)
            self.finishFlowOnConfirm?()
        }

        eventCoordination.onCancel = { [weak self, weak eventView] in
            guard let self else { return }
            self.router.dismissModule(eventView)
            self.finishFlowOnCancel?()
        }
        
        eventCoordination.onHeadForCategory = { [weak self, weak eventCoordination] category in
            guard let self else { return }

            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router,
                                                                                       selectedCategory: category)
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
