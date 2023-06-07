//
//  CoordinatorFactory.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

protocol CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput
    func makeTrackerCoordinator(router: Routable) -> Coordinatable
    func makeHabitCreationCoordinator(router: Routable,
                                      tracker: TrackerViewModel?,
                                      screenAppearance: HabitScreenAppearance) -> Coordinatable & HabitCreationCoordinator
    func makeEventCreationCoordinator(router: Routable,
                                      tracker: TrackerViewModel?,
                                      screenAppearance: HabitScreenAppearance) -> Coordinatable & EventCreationCoordinator
    func makeCategoryCoordinator(router: Routable, selectedCategory: String?) -> Coordinatable & CategoryCoordinatorOutput
    func makeStatisticsCoordinator(router: Routable) -> Coordinatable
}

final class CoordinatorFactory {
    private let modulesFactory: ModulesFactoryProtocol = ModulesFactory()
}

extension CoordinatorFactory: CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput {
        let defaultsStorageService = DefaultsStorageService()
        return AppCoordinator(coordinatorsFactory: self,
                              modulesFactory: modulesFactory,
                              router: router,
                              defaultsStorageService: defaultsStorageService)
    }
    
    func makeTrackerCoordinator(router: Routable) -> Coordinatable {
        TrackerCoordinator(coordinatorsFactory: self,
                           modulesFactory: modulesFactory,
                           router: router)
    }
    
    func makeHabitCreationCoordinator(router: Routable, tracker: TrackerViewModel?, screenAppearance: HabitScreenAppearance) -> Coordinatable & HabitCreationCoordinator {
        HabitCreationCoordinator(coordinatorsFactory: self,
                                 modulesFactory: modulesFactory,
                                 router: router,
                                 tracker: tracker,
                                 screenAppearance: screenAppearance)
    }
    
    func makeEventCreationCoordinator(router: Routable, tracker: TrackerViewModel?, screenAppearance: HabitScreenAppearance) -> Coordinatable & EventCreationCoordinator {
        EventCreationCoordinator(coordinatorsFactory: self,
                                 modulesFactory: modulesFactory,
                                 router: router,
                                 tracker: tracker,
                                 screenAppearance: screenAppearance)
    }
    
    func makeStatisticsCoordinator(router: Routable) -> Coordinatable {
        StatisticsCoordinator(coordinatorsFactory: self,
                              modulesFactory: modulesFactory,
                              router: router)
    }
    
    func makeCategoryCoordinator(router: Routable, selectedCategory: String?) -> Coordinatable & CategoryCoordinatorOutput {
        CategoryCoordinator(coordinatorsFactory: self,
                            modulesFactory: modulesFactory,
                            router: router,
                            selectedCategory: selectedCategory)
    }
}
