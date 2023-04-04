//
//  MainFlowCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

protocol AppCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class AppCoordinator : BaseCoordinator, Coordinatable, AppCoordinatorOutput {
    
    var finishFlow: (() -> Void)?
    
    private var factory: CoordinatorsFactoryProtocol
    private var router: Routable
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, router: Routable) {
        self.factory = coordinatorsFactory
        self.router = router
    }
    
    func startFlow() {
        routeToTabBarController()
        createTrackersFlow()
        createStatisticsFlow()
    }
}

private extension AppCoordinator {
    func routeToTabBarController() {
        let tabBarController = MainTabBarController()
        router.setRootViewController(viewController: tabBarController)
    }
    
    func createTrackersFlow() {
        let coordinator = factory.makeTrackerCoordinator(router: router)
        addDependency(coordinator)
        coordinator.startFlow()
    }
    
    func createStatisticsFlow() {
        let coordinator = factory.makeStatisticsCoordinator(router: router)
        addDependency(coordinator)
        coordinator.startFlow()
    }
}
