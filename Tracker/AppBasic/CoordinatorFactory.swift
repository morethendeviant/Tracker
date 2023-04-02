//
//  CoordinatorFactory.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

protocol CoordinatorsFactoryProtocol {
    func makeTrackerCoordinator(router: Routable) -> Coordinatable
//    func makeAuthCoordinator(router: Routable) -> Coordinatable & AuthCoordinatorOutput
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput
    func makeStatisticsCoordinator(router: Routable) -> Coordinatable
//    func makeProfileCoordinator(router: Routable) -> Coordinatable & ProfileFlowCoordinatorOutput
}

final class CoordinatorFactory {
    private let modulesFactory: ModulesFactoryProtocol = ModulesFactory()
}

extension CoordinatorFactory: CoordinatorsFactoryProtocol {
    func makeTrackerCoordinator(router: Routable) -> Coordinatable {
        TrackerCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
//
//    func makeAuthCoordinator(router: Routable) -> Coordinatable & AuthCoordinatorOutput {
//        AuthCoordinator(factory: modulesFactory, router: router)
//    }
    
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput {
        AppCoordinator(factory: self, router: router)
    }
    
    func makeStatisticsCoordinator(router: Routable) -> Coordinatable {
        StatisticsCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
//    
//    func makeProfileCoordinator(router: Routable) -> Coordinatable & ProfileFlowCoordinatorOutput {
//        ProfileFlowCoordinator(factory: modulesFactory, router: router)
//    }
}
