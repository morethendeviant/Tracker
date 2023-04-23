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
    func makeScheduleView(weekdays: [DayOfWeek]) -> Presentable
    func makeHabitCreationView() -> Presentable
    func makeEventCreationView() -> Presentable
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
    
    func makeScheduleView(weekdays: [DayOfWeek]) -> Presentable {
        ScheduleViewController(pageTitle: "Расписание", weekdays: weekdays)
    }
    
    func makeHabitCreationView() -> Presentable {
        let tableModel = TrackerCreationTableModel.habit
        return HabitCreationViewController(pageTitle: "Новая привычка", tableDataModel: tableModel, dataStore: dataStore)
    }
    
    func makeEventCreationView() -> Presentable {
        let tableModel = TrackerCreationTableModel.event
        return HabitCreationViewController(pageTitle: "Новая привычка", tableDataModel: tableModel, dataStore: dataStore)
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
