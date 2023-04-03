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
    func makeCategorySelectView(selectedCategory: Int?) -> Presentable
}

final class ModulesFactory: ModulesFactoryProtocol {
    func makeTrackersView() -> Presentable {
        TrackersViewController()
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
        return HabitCreationViewController(pageTitle: "Новая привычка", tableDataModel: tableModel)
    }
    
    func makeEventCreationView() -> Presentable {
        let tableModel = TrackerCreationTableModel.event
        return HabitCreationViewController(pageTitle: "Новая привычка", tableDataModel: tableModel)
    }
    
    func makeCategorySelectView(selectedCategory: Int?) -> Presentable {
        return CategorySelectViewController(pageTitle: "Категория", selectedCategory: selectedCategory)
    }
    
    
    
}
