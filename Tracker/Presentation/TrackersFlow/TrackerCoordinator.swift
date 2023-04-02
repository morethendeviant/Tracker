//
//  TrackerCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation
import UIKit

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
        
        coordinatorOutput!.headForTrackerCreation = { [weak self] in
            guard let self = self else { return }
            
            let trackerCreationModule = self.modulesFactory.makeTrackerCreationView()
            var creationCoordinatorOutput = trackerCreationModule as? TrackerCreationCoordinatorProtocol
            
            creationCoordinatorOutput?.onHeadForHabit = {
                let habitView = self.modulesFactory.makeHabitCreationView()
                self.router.present(habitView)
            }
            
            creationCoordinatorOutput?.onHeadForEvent = {
                let eventView = self.modulesFactory.makeEventCreationView()
                self.router.present(eventView)
            }
            
            self.router.present(trackerCreationModule)
        }

        router.addToTabBar(trackersView)
    }
    
}
