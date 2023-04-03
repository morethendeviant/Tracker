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
        
        habitCoordinator?.onConfirm = { [weak self, habitView] in //TODO: Add confirm logic
            self?.router.dismissModule(habitView)
            self?.finishFlow?()
        }
        
        habitCoordinator?.onCancel = { [weak self, habitView] in
            self?.router.dismissModule(habitView)
            self?.finishFlow?()
        }
        
        habitCoordinator?.onHeadForCategory = { [weak self] category in
            guard let self = self else { return }
            
            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router, selectedCategory: category)
            
            self.addDependency(categoryCoordinator)


            categoryCoordinator.finishFlow = { [weak categoryCoordinator] category in
                habitCoordinator?.selectCategory(category)
                self.removeDependency(categoryCoordinator)
            }

            categoryCoordinator.startFlow()
        }
        
        habitCoordinator?.onHeadForSchedule = { [weak self] weekdays in
            guard let self = self else { return }
            
            let scheduleView = self.modulesFactory.makeScheduleView(weekdays: weekdays)
            var scheduleCoordinator = scheduleView as? ScheduleViewCoordinatorProtocol
            
            scheduleCoordinator?.onFinish = { [weak scheduleView] selectedWeekdays in
                habitCoordinator?.returnWithWeekdays(selectedWeekdays)
                self.router.dismissModule(scheduleView)
            }
            
            self.router.present(scheduleView)
        }
        
        self.router.present(habitView) { [weak self] in
            self?.finishFlow?()
        }
    }
}
