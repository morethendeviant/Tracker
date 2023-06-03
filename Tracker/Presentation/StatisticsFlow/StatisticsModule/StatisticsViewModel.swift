//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.06.2023.
//

import Foundation
import Combine

protocol StatisticsViewCoordination: AnyObject {
    var headForError: ((String) -> Void)? { get set }
}

protocol StatisticsViewModelProtocol {
    var statistics: PassthroughSubject<[StatisticsModel], Never> { get }
    
    func viewDidLoad()
}

final class StatisticsViewModel: StatisticsViewCoordination {
    var headForError: ((String) -> Void)?
    
    private var statisticsHelper: StatisticsHelperProtocol
    
    private(set) var statistics = PassthroughSubject<[StatisticsModel], Never>()
    private var cancellable: Cancellable?

    init(statisticsHelper: StatisticsHelperProtocol) {
        self.statisticsHelper = statisticsHelper
        setupNotification()
    }
}

extension StatisticsViewModel: StatisticsViewModelProtocol {
    func viewDidLoad() {
        loadData()
    }
}

private extension StatisticsViewModel {
    func setupNotification() {
        cancellable = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave,
                       object: Context.shared)
            .sink { [weak self] _ in
                self?.loadData()
            }
    }
    
    func loadData() {
        do {
            let mappedStatistics = try statisticsHelper.getStatistics().compactMap {
                switch $0 {
                case .finished(let amount):
                    let text = NSLocalizedString("trackers.finished", comment: "Statistic finished trackers amount text")
                    return amount == 0 ? nil : StatisticsModel(number: String(amount),
                                                               title: text)
                case .trackers(let amount):
                    let text = NSLocalizedString("trackers.total", comment: "Statistic total trackers amount text")
                    return amount == 0 ? nil : StatisticsModel(number: String(amount),
                                                               title: text)
                case .idealDays(let amount):
                    let text = NSLocalizedString("trackers.ideal", comment: "Statistic ideal days amount text")
                    return amount == 0 ? nil : StatisticsModel(number: String(amount),
                                                               title: text)
                }
            }
            
            statistics.send(mappedStatistics)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
}

// MARK: - Error Handling

extension StatisticsViewModel: ErrorHandlerDelegate {
    func handleError(message: String) {
        headForError?(message)
    }
}
