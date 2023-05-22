//
//  ScheduleViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 23.04.2023.
//

import Foundation

protocol ScheduleCoordination {
    var onFinish: (([DayOfWeek]) -> Void)? { get set }
}

protocol ScheduleViewModelProtocol {
    var selectedDays: [DayOfWeek] { get }
    var daysAmount: Int { get }
    
    func dayNameAt(index: Int) -> String?
    func setDayAt(index: Int, to state: Bool)
    func doneButtonTapped()
    func isDaySelectedAt(index: Int) -> Bool
}

final class ScheduleViewModel: ScheduleCoordination {
    var onFinish: (([DayOfWeek]) -> Void)?
    
    private(set) var selectedDays: [DayOfWeek] = []

    init(weekdays: [DayOfWeek]) {
        self.selectedDays = weekdays
    }
}

extension ScheduleViewModel: ScheduleViewModelProtocol {
    var daysAmount: Int {
        DayOfWeek.count
    }
    
    func setDayAt(index: Int, to state: Bool) {
        let day =  DayOfWeek.dayFromNumber(index)
        if state {
            selectedDays.append(day)
        } else {
            selectedDays.removeAll(where: { $0 == day })
        }
    }
    
    func dayNameAt(index: Int) -> String? {
        DayOfWeek.fullNameFor(index)
    }
    
    func doneButtonTapped() {
        onFinish?(selectedDays)
    }
    
    func isDaySelectedAt(index: Int) -> Bool {
        selectedDays.map { $0.rawValue }.contains(index)
    }
    
}
