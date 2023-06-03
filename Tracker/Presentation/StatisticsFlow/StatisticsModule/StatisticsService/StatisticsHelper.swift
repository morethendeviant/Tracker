//
//  StatisticsHelper.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 03.06.2023.
//

import Foundation

protocol StatisticsHelperProtocol {
    func getStatistics() throws -> [StatisticsEntityModel]
}

final class StatisticsHelper {
    
    private let dataProvider: StatisticsDataStoreProtocol
    
    init(dataProvider: StatisticsDataStoreProtocol) {
        self.dataProvider = dataProvider
    }
}

extension StatisticsHelper: StatisticsHelperProtocol {
    func getStatistics() throws -> [StatisticsEntityModel] {
        let (trackers, records) = try dataProvider.loadRawDataForStatistics()
        var recordsDatesSet: [Date: Int] = [:]
        print(records)
        records.forEach { record in
            if recordsDatesSet[record.date] == nil {
                recordsDatesSet[record.date] = 1
            } else {
                recordsDatesSet[record.date]! += 1
            }
        }
        
        var trackersDaysSet: [DayOfWeek: Int] = [:]
        
        trackers.forEach { tracker in
            let days = DayOfWeek.numbersToDays(tracker.schedule)
            days.forEach { day in
                if trackersDaysSet[day] == nil {
                    trackersDaysSet[day] = 1
                } else {
                    trackersDaysSet[day]! += 1
                }
            }
        }
        
        var idealDays = 0
        recordsDatesSet.forEach { key, value in
            if let daysAmount = trackersDaysSet[key.getDayOfWeek()], daysAmount == value {
                idealDays += 1
            }
        }
        
        return [.trackers(trackers.count), .finished(records.count), .idealDays(idealDays)]
    }
}
