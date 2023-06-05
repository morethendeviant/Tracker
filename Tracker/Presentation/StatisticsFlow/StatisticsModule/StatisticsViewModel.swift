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

// MARK: - Statistics ViewModel Protocol

extension StatisticsViewModel: StatisticsViewModelProtocol {
    func viewDidLoad() {
        loadData()
    }
}

// MARK: - Private Methods

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
            let loadedStatistics = try statisticsHelper.getStatistics()
            if loadedStatistics.filter({ $0 == .trackers(0) }).isEmpty {
                let mappedStatistics = loadedStatistics.map {
                    switch $0 {
                    case .finished(let amount):
                        let text = NSLocalizedString("trackers.finished", comment: "Statistic finished trackers amount text")
                        return StatisticsModel(number: amount, title: text)
                    case .trackers(let amount):
                        let text = NSLocalizedString("trackers.total", comment: "Statistic total trackers amount text")
                        return StatisticsModel(number: amount, title: text)
                    case .idealDays(let amount):
                        let text = NSLocalizedString("trackers.ideal", comment: "Statistic ideal days amount text")
                        return StatisticsModel(number: amount, title: text)
                    }
                }
                
                statistics.send(mappedStatistics)
            } else {
                statistics.send([])
            }
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
