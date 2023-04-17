//
//  TrackerCreationCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation
 
protocol HabitCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)? { get set }
    var finishFlowOnCreate: (() -> Void)? { get set }
}

final class HabitCreationCoordinator: BaseCoordinator, Coordinatable, HabitCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)?
    var finishFlowOnCreate: (() -> Void)?
    
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
        let habitCoordinator = habitView as? HabitCreationCoordinatorProtocol
        
        habitCoordinator?.onCreate = { [weak self, weak habitView] in
            guard let self else { return }
            self.router.dismissModule(habitView)
            self.finishFlowOnCreate?()
        }
        
        habitCoordinator?.onCancel = { [weak self, weak habitView] in
            guard let self else { return }
            self.router.dismissModule(habitView)
            self.finishFlowOnCancel?()
        }
        
        habitCoordinator?.onHeadForCategory = { [weak self, weak habitCoordinator] category in
            guard let self else { return }
            
            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router, selectedCategory: category)
            
            self.addDependency(categoryCoordinator)
            
            categoryCoordinator.finishFlow = { [weak categoryCoordinator] category in
                habitCoordinator?.selectCategory(category)
                self.removeDependency(categoryCoordinator)
            }

            categoryCoordinator.startFlow()
        }
        
        habitCoordinator?.onHeadForSchedule = { [weak self, weak habitCoordinator] weekdays in
            guard let self else { return }

            let scheduleView = self.modulesFactory.makeScheduleView(weekdays: weekdays)
            var scheduleCoordinator = scheduleView as? ScheduleViewCoordinatorProtocol

            scheduleCoordinator?.onFinish = { [weak scheduleView] selectedWeekdays in
                habitCoordinator?.returnWithWeekdays(selectedWeekdays)
                self.router.dismissModule(scheduleView)
            }

            self.router.present(scheduleView)
        }
        
        self.router.present(habitView) { [weak self] in
            self?.finishFlowOnCancel?()
        }
    }
}
