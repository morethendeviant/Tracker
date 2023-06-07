//
//  TrackerCreationCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation
 
protocol HabitCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)? { get set }
    var finishFlowOnConfirm: (() -> Void)? { get set }
}

final class HabitCreationCoordinator: BaseCoordinator, Coordinatable, HabitCreationCoordinatorOutput {
    var finishFlowOnCancel: (() -> Void)?
    var finishFlowOnConfirm: (() -> Void)?
    
    private var coordinatorsFactory: CoordinatorsFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    private var tracker: TrackerViewModel?
    private var screenAppearance: HabitScreenAppearance
    
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable, tracker: TrackerViewModel?, screenAppearance: HabitScreenAppearance) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
        self.tracker = tracker
        self.screenAppearance = screenAppearance
    }
    
    func startFlow() {
        performFlow()
    }
}

// MARK: - Private Methods

private extension HabitCreationCoordinator {
    func performFlow() {
        let habitModule = self.modulesFactory.makeHabitCreationView(tableDataModel: tracker,
                                                                    screenAppearance: screenAppearance)
        let habitView = habitModule.view
        let habitCoordination = habitModule.coordination
        
        habitCoordination.onCreate = { [weak self, weak habitView] in
            guard let self else { return }
            self.router.dismissModule(habitView)
            self.finishFlowOnConfirm?()
        }
        
        habitCoordination.onCancel = { [weak self, weak habitView] in
            guard let self else { return }
            self.router.dismissModule(habitView)
            self.finishFlowOnCancel?()
        }
        
        habitCoordination.onHeadForCategory = { [weak self, weak habitCoordination] category in
            guard let self else { return }
            
            var categoryCoordinator = self.coordinatorsFactory.makeCategoryCoordinator(router: router,
                                                                                       selectedCategory: category)
            
            self.addDependency(categoryCoordinator)
            
            categoryCoordinator.finishFlow = { [weak categoryCoordinator] category in
                habitCoordination?.selectCategory(category)
                self.removeDependency(categoryCoordinator)
            }

            categoryCoordinator.startFlow()
        }
        
        habitCoordination.onHeadForSchedule = { [weak self, weak habitCoordination] weekdays in
            guard let self else { return }
            let scheduleModule = self.modulesFactory.makeScheduleView(weekdays: weekdays)
            let scheduleView = scheduleModule.view
            var scheduleCoordination = scheduleModule.coordination

            scheduleCoordination.onFinish = { [weak scheduleView] selectedWeekdays in
                habitCoordination?.returnWithWeekdays(selectedWeekdays)
                self.router.dismissModule(scheduleView)
            }

            self.router.present(scheduleView)
        }
        
        self.router.present(habitView) { [weak self] in
            self?.finishFlowOnCancel?()
        }
    }
}
