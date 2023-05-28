//
//  ModulesFactory.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

protocol ModulesFactoryProtocol {
    func makeTrackersView() -> (view: Presentable, coordination: TrackersViewCoordination)
    func makeStatisticsView() -> Presentable
    func makeTrackerSelectView() -> Presentable
    func makeScheduleView(weekdays: [DayOfWeek]) -> (view: Presentable, coordination: ScheduleCoordination)
    func makeHabitCreationView() -> (view: Presentable, coordination: HabitCreationCoordination)
    func makeEventCreationView() -> (view: Presentable, coordination: EventCreationCoordination)
    func makeCategorySelectView(selectedCategory: String?) -> (view: Presentable, coordination: CategorySelectCoordination)
    func makeCategoryCreateView() -> (view: Presentable, coordination: CategoryCreateCoordination)
    func makeOnboardingPageView() -> Presentable
}

final class ModulesFactory: ModulesFactoryProtocol {
    
    func makeTrackersView() -> (view: Presentable, coordination: TrackersViewCoordination) {
        let dataProvider: TrackerDataStoreProtocol = DataStore()
        let viewModel = TrackersListViewModel(dataProvider: dataProvider)
        let view = TrackersViewController(viewModel: viewModel, diffableDataSourceProvider: viewModel)
        return (view, viewModel)
    }
    
    func makeStatisticsView() -> Presentable {
        StatisticsViewController()
    }
    
    func makeTrackerSelectView() -> Presentable {
        let pageTitle = NSLocalizedString("trackerCreation", comment: "Tracker creation page name")
        return TrackerSelectViewController(pageTitle: pageTitle)
    }
    
    func makeScheduleView(weekdays: [DayOfWeek]) -> (view: Presentable, coordination: ScheduleCoordination) {
        let viewModel = ScheduleViewModel(weekdays: weekdays)
        let pageTitle = NSLocalizedString("schedule", comment: "Schedule page name")
        let view = ScheduleViewController(viewModel: viewModel, pageTitle: pageTitle)
        return (view, viewModel)
    }
    
    func makeHabitCreationView() -> (view: Presentable, coordination: HabitCreationCoordination) {
        let tableModel = TrackerCreationTableModel.habit
        let dataStore: TrackerCreationDataStoreProtocol = DataStore()
        let viewModel = HabitCreationViewModel(dataStore: dataStore, tableDataModel: tableModel)
        let pageTitle = NSLocalizedString("newHabit", comment: "New habit page name")
        let view = HabitCreationViewController(viewModel: viewModel, pageTitle: pageTitle)
        return (view, viewModel)
    }
    
    func makeEventCreationView() -> (view: Presentable, coordination: EventCreationCoordination) {
        let tableModel = TrackerCreationTableModel.event
        let dataStore: TrackerCreationDataStoreProtocol = DataStore()
        let viewModel = HabitCreationViewModel(dataStore: dataStore, tableDataModel: tableModel)
        let pageTitle = NSLocalizedString("newEvent", comment: "New event page name")
        let view = HabitCreationViewController(viewModel: viewModel, pageTitle: pageTitle)
        return (view, viewModel)

    }
    
    func makeCategorySelectView(selectedCategory: String?) -> (view: Presentable, coordination: CategorySelectCoordination) {
        let dataStore: CategorySelectDataStoreProtocol = DataStore()
        let viewModel = CategorySelectViewModel(dataProvider: dataStore, selectedCategory: selectedCategory)
        let pageTitle = NSLocalizedString("category", comment: "Categories page name")
        let view = CategorySelectViewController(dataSourceProvider: viewModel,
                                                viewModel: viewModel,
                                                pageTitle: pageTitle)
        return (view, viewModel)
    }
    
    func makeCategoryCreateView() -> (view: Presentable, coordination: CategoryCreateCoordination) {
        let viewModel = CategoryCreateViewModel()
        let pageTitle = NSLocalizedString("newCategory", comment: "New category page name")
        let view = CategoryCreateViewController(viewModel: viewModel, pageTitle: pageTitle)
        return (view, viewModel)
    }
    
    func makeOnboardingPageView() -> Presentable {
        let defaultsStorageService = DefaultsStorageService()
        return OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, defaultsStorageService: defaultsStorageService)
    }
}
