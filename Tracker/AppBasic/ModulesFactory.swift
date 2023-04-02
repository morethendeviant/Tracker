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
    func makeScheduleView() -> Presentable
    func makeHabitCreationView() -> Presentable
    func makeEventCreationView() -> Presentable
    func makeCategorySelectView() -> Presentable
    
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
    
    func makeScheduleView() -> Presentable {
        ScheduleViewController(pageTitle: "Расписание")
    }
    
    func makeHabitCreationView() -> Presentable {
        let dataSource = HabitCreationDataSource()
        return HabitCreationViewController(pageTitle: "Новая привычка", dataSource: dataSource)
    }
    
    func makeEventCreationView() -> Presentable {
        let dataSource = EventCreationDataSource()
        return HabitCreationViewController(pageTitle: "Новое нерегулярное событие", dataSource: dataSource)
    }
    
    func makeCategorySelectView() -> Presentable {
        return CategorySelectViewController(pageTitle: "Категория")
    }
    
    
    
}
