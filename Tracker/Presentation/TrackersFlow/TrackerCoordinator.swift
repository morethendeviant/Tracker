//
//  TrackerCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

final class TrackerCoordinator: BaseCoordinator, Coordinatable {
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

private extension TrackerCoordinator {
    func performFlow() {
        let trackersView = modulesFactory.makeTrackersView()
        var coordinatorOutput = trackersView as? TrackersViewCoordinatorProtocol
        
        coordinatorOutput!.headForTrackerSelect = { [weak self] in
            guard let self = self else { return }
            
            let trackerSelectModule = self.modulesFactory.makeTrackerSelectView()
            var creationCoordinatorOutput = trackerSelectModule as? TrackerSelectCoordinatorProtocol
            
            creationCoordinatorOutput?.onHeadForHabit = {
                let habitCreationCoordinator = self.coordinatorsFactory.makeHabitCreationCoordinator(router: self.router)
                
                habitCreationCoordinator.finishFlowOnCreate = { [weak habitCreationCoordinator ] in
                    coordinatorOutput?.updateCategories()
                    self.removeDependency(habitCreationCoordinator)
                    self.router.dismissModule(trackerSelectModule)
                }
                
                habitCreationCoordinator.finishFlowOnCancel = { [weak habitCreationCoordinator ] in
                    self.removeDependency(habitCreationCoordinator)
                }
                
                self.addDependency(habitCreationCoordinator)
                habitCreationCoordinator.startFlow()
            }
            
            creationCoordinatorOutput?.onHeadForEvent = {
                let eventCreationCoordinator = self.coordinatorsFactory.makeEventCreationCoordinator(router: self.router)
                
                eventCreationCoordinator.finishFlowOnCreate = { [weak eventCreationCoordinator] in
                    coordinatorOutput?.updateCategories()
                    self.removeDependency(eventCreationCoordinator)
                    self.router.dismissModule(trackerSelectModule)
                }
                
                eventCreationCoordinator.finishFlowOnCancel = { [weak eventCreationCoordinator ] in
                    self.removeDependency(eventCreationCoordinator)
                }
                
                self.addDependency(eventCreationCoordinator)
                eventCreationCoordinator.startFlow()
            }
            
            self.router.present(trackerSelectModule)
        }

        router.addToTabBar(trackersView)
    }
}
