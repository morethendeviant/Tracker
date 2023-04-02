//
//  TrackerCreationCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation
 
protocol HabitCreationCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class HabitCreationCoordinator: BaseCoordinator, Coordinatable, HabitCreationCoordinatorOutput {
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

private extension HabitCreationCoordinator {
    func performFlow() {
        let habitView = self.modulesFactory.makeHabitCreationView()
        
        var habitCoordinator = habitView as? HabitCreationCoordinatorProtocol
        
        habitCoordinator?.onCancel = { [weak self] in
            self?.router.dismissModule(habitView)
            self?.finishFlow?()
        }
        
        habitCoordinator?.onHeadForCategory = { [weak self] in
            guard let self = self else { return }
            
            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router)
            self.addDependency(categoryCoordinator)
            categoryCoordinator.finishFlow = { [weak categoryCoordinator] in
                self.removeDependency(categoryCoordinator)
            }
            
            categoryCoordinator.startFlow()
        }
        
        habitCoordinator?.onHeadForSchedule = { [weak self] in
            guard let self = self else { return }
            
            let scheduleView = self.modulesFactory.makeScheduleView()
            self.router.present(scheduleView)
        }
        
        self.router.present(habitView) { [weak self] in
            self?.finishFlow?()
        }
    }
}
