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
        let trackersModule = modulesFactory.makeTrackersView()
        let trackersView = trackersModule.view
        let trackersCoordination = trackersModule.coordination
        
        trackersCoordination.headForTrackerSelect = { [weak self, weak trackersCoordination] in
            guard let self else { return }
            
            let trackerSelectModule = self.modulesFactory.makeTrackerSelectView()
            var trackerSelectCoordinatorOutput = trackerSelectModule as? TrackerSelectCoordinatorProtocol
            
            trackerSelectCoordinatorOutput?.onHeadForHabit = { [weak trackerSelectModule] in
                let habitCreationCoordinator = self.coordinatorsFactory.makeHabitCreationCoordinator(router: self.router)
                
                habitCreationCoordinator.finishFlowOnCreate = { [weak habitCreationCoordinator] in
                    trackersCoordination?.returnOnCreate()
                    self.removeDependency(habitCreationCoordinator)
                    self.router.dismissModule(trackerSelectModule)
                }
                
                habitCreationCoordinator.finishFlowOnCancel = { [weak habitCreationCoordinator ] in
                    self.removeDependency(habitCreationCoordinator)
                }
                
                self.addDependency(habitCreationCoordinator)
                habitCreationCoordinator.startFlow()
            }
            
            trackerSelectCoordinatorOutput?.onHeadForEvent = { [weak trackerSelectModule] in
                let eventCreationCoordinator = self.coordinatorsFactory.makeEventCreationCoordinator(router: self.router)
                
                eventCreationCoordinator.finishFlowOnCreate = { [weak eventCreationCoordinator] in
                    trackersCoordination?.returnOnCreate()
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
        
        trackersCoordination.headForError = { [weak self] message in
            self?.router.presentAlert(message: message)
        }
        
        router.addToTabBar(trackersView)
    }
}
