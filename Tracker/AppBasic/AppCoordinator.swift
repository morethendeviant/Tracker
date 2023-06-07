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
    private var defaultsStorageService: DefaultsStorageService
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable, defaultsStorageService: DefaultsStorageService) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
        self.defaultsStorageService = defaultsStorageService
    }
    
    func startFlow() {
        if defaultsStorageService.onboardingWasShown {
            routeToTabBarController()
            createTrackersFlow()
            createStatisticsFlow()
        } else {
            routeToOnboarding()
        }
    }
}

private extension AppCoordinator {
    func routeToOnboarding() {
        let pageView = modulesFactory.makeOnboardingPageView()
        var pageViewCoordinator = pageView as? OnboardingPageViewControllerCoordinator
        pageViewCoordinator?.onProceed = { [weak self] in
            self?.defaultsStorageService.onboardingWasShown = true
            self?.startFlow()
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
