//
//  CoordinatorFactory.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

protocol CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput
    func makeTrackerCoordinator(router: Routable) -> Coordinatable
    func makeHabitCreationCoordinator(router: Routable) -> Coordinatable & HabitCreationCoordinator
    func makeEventCreationCoordinator(router: Routable) -> Coordinatable & EventCreationCoordinator
    func makeCategoryCoordinator(router: Routable, selectedCategory: Int?) -> Coordinatable & CategoryCoordinatorOutput
    func makeStatisticsCoordinator(router: Routable) -> Coordinatable
}

final class CoordinatorFactory {
    private let modulesFactory: ModulesFactoryProtocol = ModulesFactory()
}

extension CoordinatorFactory: CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput {
        AppCoordinator(coordinatorsFactory: self, router: router)
    }
    
    func makeTrackerCoordinator(router: Routable) -> Coordinatable {
        TrackerCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeHabitCreationCoordinator(router: Routable) -> Coordinatable & HabitCreationCoordinator {
        HabitCreationCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeEventCreationCoordinator(router: Routable) -> Coordinatable & EventCreationCoordinator {
        EventCreationCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeStatisticsCoordinator(router: Routable) -> Coordinatable {
        StatisticsCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeCategoryCoordinator(router: Routable, selectedCategory: Int?) -> Coordinatable & CategoryCoordinatorOutput {
        CategoryCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router,selectedCategory: selectedCategory)
    }
}
