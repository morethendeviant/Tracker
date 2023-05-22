//
//  MainFlowCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

protocol AppCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class AppCoordinator: BaseCoordinator, Coordinatable, AppCoordinatorOutput {
    
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
        routeToOnboarding()
    }
}

private extension AppCoordinator {
    func routeToOnboarding() {
        let pageView = modulesFactory.makeOnboardingPageView()
        var pageViewCoordinator = pageView as? OnboardingPageViewControllerCoordinator
        pageViewCoordinator?.onProceed = { [weak self] in
            self?.routeToTabBarController()
            self?.createTrackersFlow()
            self?.createStatisticsFlow()
        }
        
        router.setRootViewController(viewController: pageView)
    }
    
    func routeToTabBarController() {
        let tabBarController = MainTabBarController()
        router.setRootViewController(viewController: tabBarController)
    }
    
    func createTrackersFlow() {
        let coordinator = coordinatorsFactory.makeTrackerCoordinator(router: router)
        addDependency(coordinator)
        coordinator.startFlow()
    }
    
    func createStatisticsFlow() {
        let coordinator = coordinatorsFactory.makeStatisticsCoordinator(router: router)
        addDependency(coordinator)
        coordinator.startFlow()
    }
}
