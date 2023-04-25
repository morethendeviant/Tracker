//
//  ModulesFactory.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import Foundation

protocol ModulesFactoryProtocol {
    func makeTrackersView() -> Presentable
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
    let dataStore: TrackerDataStoreProtocol = DataStore()
    
    func makeTrackersView() -> Presentable {
        return TrackersViewController()
    }
    
    func makeStatisticsView() -> Presentable {
        StatisticsViewController()
    }
    
    func makeTrackerSelectView() -> Presentable {
        TrackerSelectViewController(pageTitle: "Создание трекера")
    }
    
    func makeScheduleView(weekdays: [DayOfWeek]) -> (view: Presentable, coordination: ScheduleCoordination) {
        let viewModel = ScheduleViewModel(weekdays: weekdays)
        let view = ScheduleViewController(viewModel: viewModel, pageTitle: "Расписание")
        return (view, viewModel)
    }
    
    func makeHabitCreationView() -> (view: Presentable, coordination: HabitCreationCoordination) {
        let tableModel = TrackerCreationTableModel.habit
        let dataStore: TrackerDataStoreProtocol = DataStore()
        let viewModel = HabitCreationViewModel(dataStore: dataStore, tableDataModel: tableModel)
        let view = HabitCreationViewController(viewModel: viewModel, pageTitle: "Новая привычка")
        return (view, viewModel)
    }
    
    func makeEventCreationView() -> (view: Presentable, coordination: EventCreationCoordination) {
        let tableModel = TrackerCreationTableModel.event
        let dataStore: TrackerDataStoreProtocol = DataStore()
        let viewModel = HabitCreationViewModel(dataStore: dataStore, tableDataModel: tableModel)
        let view = HabitCreationViewController(viewModel: viewModel, pageTitle: "Новая привычка")
        return (view, viewModel)

    }
    
    func makeCategorySelectView(selectedCategory: String?) -> (view: Presentable, coordination: CategorySelectCoordination) {
        let viewModel = CategorySelectViewModel()
        let view = CategorySelectViewController(viewModel: viewModel,
                                                pageTitle: "Категория",
                                                selectedCategory: selectedCategory)
        return (view, viewModel)
    }
    
    func makeCategoryCreateView() -> (view: Presentable, coordination: CategoryCreateCoordination) {
        let viewModel = CategoryCreateViewModel()
        let view = CategoryCreateViewController(viewModel: viewModel, pageTitle: "Новая категория")
        return (view, viewModel)
    }
    
    func makeOnboardingPageView() -> Presentable {
        return OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
}
