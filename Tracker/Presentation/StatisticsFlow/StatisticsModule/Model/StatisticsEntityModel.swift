//
//  StatisticsEntityModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.06.2023.
//

enum StatisticsEntityModel: Equatable {
    case finished(Int)
    case trackers(Int)
    case idealDays(Int)
}

extension StatisticsEntityModel {
    static func == (lhs: StatisticsEntityModel, rhs: StatisticsEntityModel) -> Bool {
        switch (lhs, rhs) {
        case (.trackers(let lInt), .trackers(let rInt)): return lInt == rInt
        default: return false
        }
    }
}
