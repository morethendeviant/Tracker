//
//  TrackerCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

final class TrackerCoordinator: BaseCoordinator, Coordinatable {
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

private extension TrackerCoordinator {
    func performFlow() {
        let trackersModule = modulesFactory.makeTrackersView()
        let trackersView = trackersModule.view
        let trackersCoordination = trackersModule.coordination
        
        trackersCoordination.headForTrackerSelect = { [weak self, weak trackersCoordination] in
            guard let self else { return }
            
            let trackerSelectModule = self.modulesFactory.makeTrackerSelectView()
            var trackerSelectCoordinatorOutput = trackerSelectModule as? TrackerSelectCoordinatorProtocol
            
            trackerSelectCoordinatorOutput?.onHeadForHabit = { [weak trackerSelectModule] in
                let createButtonText = NSLocalizedString("create", comment: "Create button title")
                let pageTitle = NSLocalizedString("newHabit", comment: "New habit page name")
                let screenAppearance = HabitScreenAppearance(pageTitle: pageTitle, confirmButtonText: createButtonText)
                
                let habitCreationCoordinator = self.coordinatorsFactory
                    .makeHabitCreationCoordinator(router: self.router,
                                                  tracker: nil,
                                                  screenAppearance: screenAppearance)
                
                habitCreationCoordinator.finishFlowOnConfirm = { [weak habitCreationCoordinator] in
                    trackersCoordination?.returnOnConfirm()
                    self.removeDependency(habitCreationCoordinator)
                    self.router.dismissModule(trackerSelectModule)
                }
                
                habitCreationCoordinator.finishFlowOnCancel = { [weak habitCreationCoordinator ] in
                    self.removeDependency(habitCreationCoordinator)
                }
                
                self.addDependency(habitCreationCoordinator)
                habitCreationCoordinator.startFlow()
            }
            
            trackerSelectCoordinatorOutput?.onHeadForEvent = { [weak trackerSelectModule] in
                let createButtonText = NSLocalizedString("create", comment: "Create button title")
                let pageTitle = NSLocalizedString("newEvent", comment: "New event page name")
                let screenAppearance = HabitScreenAppearance(pageTitle: pageTitle, confirmButtonText: createButtonText)
                let eventCreationCoordinator = self.coordinatorsFactory
                    .makeEventCreationCoordinator(router: self.router,
                                                  tracker: nil,
                                                  screenAppearance: screenAppearance)
                
                eventCreationCoordinator.finishFlowOnConfirm = { [weak eventCreationCoordinator] in
                    trackersCoordination?.returnOnConfirm()
                    self.removeDependency(eventCreationCoordinator)
                    self.router.dismissModule(trackerSelectModule)
                }
                
                eventCreationCoordinator.finishFlowOnCancel = { [weak eventCreationCoordinator ] in
                    self.removeDependency(eventCreationCoordinator)
                }
                
                self.addDependency(eventCreationCoordinator)
                eventCreationCoordinator.startFlow()
            }
            
            self.router.present(trackerSelectModule)
        }
        
        trackersCoordination.headForHabit = { [weak self] tracker in
            guard let self else { return }
            let saveButtonText = NSLocalizedString("save", comment: "Save button title")
            let pageTitle = NSLocalizedString("editHabit", comment: "Edit habit page name")
            let screenAppearance = HabitScreenAppearance(pageTitle: pageTitle, confirmButtonText: saveButtonText)
            let habitCreationCoordinator = self.coordinatorsFactory
                .makeHabitCreationCoordinator(router: self.router,
                                              tracker: tracker,
                                              screenAppearance: screenAppearance)
            
            habitCreationCoordinator.finishFlowOnConfirm = { [weak habitCreationCoordinator, weak trackersCoordination] in
                trackersCoordination?.returnOnConfirm()
                self.removeDependency(habitCreationCoordinator)
            }
            
            habitCreationCoordinator.finishFlowOnCancel = { [weak habitCreationCoordinator ] in
                self.removeDependency(habitCreationCoordinator)
            }
            
            self.addDependency(habitCreationCoordinator)
            habitCreationCoordinator.startFlow()
        }
        
        trackersCoordination.headForEvent = { [weak self] tracker in
            guard let self else { return }
            let saveButtonText = NSLocalizedString("save", comment: "Save button title")
            let pageTitle = NSLocalizedString("editEvent", comment: "Edit event page name")
            let screenAppearance = HabitScreenAppearance(pageTitle: pageTitle, confirmButtonText: saveButtonText)
            let eventCreationCoordinator = self.coordinatorsFactory
                .makeEventCreationCoordinator(router: self.router,
                                              tracker: tracker,
                                              screenAppearance: screenAppearance)
            
            eventCreationCoordinator.finishFlowOnConfirm = { [weak eventCreationCoordinator, weak trackersCoordination] in
                trackersCoordination?.returnOnConfirm()
                self.removeDependency(eventCreationCoordinator)
            }
            
            eventCreationCoordinator.finishFlowOnCancel = { [weak eventCreationCoordinator ] in
                self.removeDependency(eventCreationCoordinator)
            }
            
            self.addDependency(eventCreationCoordinator)
            eventCreationCoordinator.startFlow()
        }
        
        trackersCoordination.headForFilter = { [weak self, weak trackersCoordination] filter in
            guard let self else { return }
            let filterModule = modulesFactory.makeFilterModule(selectedFilter: filter)
            let filterView = filterModule.view
            var filterCoordination = filterModule.coordination
            
            filterCoordination.onFinish = { [weak self, weak filterView] filter in
                self?.router.dismissModule(filterView)
                trackersCoordination?.returnOnFilter(selectedFilter: filter)
            }
            
            self.router.present(filterView)
        }
        
        trackersCoordination.headForError = { [weak self] message in
            self?.router.presentAlert(message: message)
        }
        
        trackersCoordination.headForAlert = { [weak self] alertModel in
            self?.router.presentActionSheet(alertModel: alertModel)
        }
        
        router.addToTabBar(trackersView)
    }
}
