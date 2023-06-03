//
//  StatisticsCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

final class StatisticsCoordinator: BaseCoordinator, Coordinatable {
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

private extension StatisticsCoordinator {
    func performFlow() {
        let statisticsModule = modulesFactory.makeStatisticsView()
        let statisticsView = statisticsModule.view
        let statisticsCoordination = statisticsModule.coordination
        
        statisticsCoordination.headForError = { [weak self] message in
            self?.router.presentAlert(message: message)
        }
        
        router.addToTabBar(statisticsView)
    }
}
