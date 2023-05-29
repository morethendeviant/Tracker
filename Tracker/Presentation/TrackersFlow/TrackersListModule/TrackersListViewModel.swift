//
//  TrackersListViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 26.04.2023.
//

import Foundation

// MARK: - Protocols

protocol TrackersViewCoordination: AnyObject {
    var headForTrackerSelect: (() -> Void)? { get set }
    var headForError: ((String) -> Void)? { get set }
    
    func returnOnCreate()
}

protocol ErrorHandlerDelegate: AnyObject {
    func handleError(message: String)
}

protocol TrackersListViewModelProtocol {
    var visibleCategories: [TrackerCategory] { get }
    var visibleCategoriesObserver: Observable<[TrackerCategory]> { get }
    
    var tracker: Tracker? { get }
    var trackerObserver: Observable<Tracker?> { get }
    
    var date: Date { get }
    var searchText: String? { get }
    var lastSectionIndex: Int { get }
    
    func sectionNameAt(_ index: Int) -> String
    func plusButtonTapped()
    func dateChangedTo(_ date: Date)
    func searchTextChangedTo(_ text: String?)
    func deleteTrackerAt(indexPath: IndexPath)
    func pinTrackerAt(indexPath: IndexPath)
    func editTrackerAt(indexPath: IndexPath)
    func trackerIsPinnedAt(indexPath: IndexPath) -> Bool
}

protocol TrackersDataSourceProvider {
    func addRecordWithId(_ id: String)
    func removeRecordWithId(_ id: String)
    func cellIsMarkedWithId(_ id: String) -> Bool
    func daysAmountWithId(_ id: String) -> Int
    func changeStateForTracker(_ tracker: Tracker)
}

// MARK: - TrackersList View Model

final class TrackersListViewModel: TrackersViewCoordination {
    func returnOnCreate() {
        dateChangedTo(date)
    }
    
    var headForTrackerSelect: (() -> Void)?
    var headForError: ((String) -> Void)?
    
    private var dataProvider: TrackerDataStoreProtocol
    
    private(set) var date: Date = Date()
    private(set) var searchText: String?
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            var pinnedTrackers: [Tracker] = []
            categories = categories.compactMap {
                let trackers = $0.trackers.compactMap { $0.isPinned ? nil : $0 }.sorted { $0.name < $1.name }
                pinnedTrackers.append(contentsOf: $0.trackers.compactMap { $0.isPinned ? $0 : nil })
                return trackers.isEmpty ? nil : TrackerCategory(name: $0.name, trackers: trackers)
            }
            
            if !pinnedTrackers.isEmpty {
                let pinnedText = NSLocalizedString("pinned", comment: "Pinned group name")
                let pinnedCategory = TrackerCategory(name: pinnedText, trackers: pinnedTrackers)
                categories.insert(pinnedCategory, at: 0)
            }
            
            visibleCategories = filtered(categories: categories)
        }
    }
    
    @Observable var visibleCategories: [TrackerCategory] = []
    
    var visibleCategoriesObserver: Observable<[TrackerCategory]> {
        $visibleCategories
    }
    
    @Observable var tracker: Tracker?
    var trackerObserver: Observable<Tracker?> {
        $tracker
    }
    
    init(dataProvider: TrackerDataStoreProtocol) {
        self.dataProvider = dataProvider
    }
}

// MARK: - Private methods

private extension TrackersListViewModel {
    func filtered(categories: [TrackerCategory]) -> [TrackerCategory] {
        categories.compactMap { category in
            guard let searchText, !searchText.isEmpty else { return category }
            let trackers = category.trackers.filter { $0.name.contains(searchText) }
            return trackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: trackers)
        }
    }
    
    func getTrackerWithId(id: String) -> Tracker? {
        categories.flatMap { $0.trackers.map { $0 } }.first(where: { $0.id == id })
    }
}

// MARK: - Trackers List View Model

extension TrackersListViewModel: TrackersListViewModelProtocol {
    func pinTrackerAt(indexPath: IndexPath) {
        do {
            let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
            try dataProvider.setTracker(tracker, pinned: !tracker.isPinned)
            dateChangedTo(date)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    func trackerIsPinnedAt(indexPath: IndexPath) -> Bool {
        visibleCategories[indexPath.section].trackers[indexPath.row].isPinned
    }
    
    func editTrackerAt(indexPath: IndexPath) {
        
    }
    
    func deleteTrackerAt(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        do {
            try dataProvider.deleteTracker(tracker)
        } catch {
            handleError(message: error.localizedDescription)
        }
        
        dateChangedTo(date)
    }
    
    var lastSectionIndex: Int {
        visibleCategories.count - 1
    }
    
    func sectionNameAt(_ index: Int) -> String {
        visibleCategories[index].name
    }
    
    func plusButtonTapped() {
        headForTrackerSelect?()
    }
    
    func dateChangedTo(_ date: Date) {
        self.date = date.onlyDate()
        let dayOfWeek = date.getDayOfWeek()
        do {
            categories = try dataProvider.fetchAllCategories().compactMap { category in
                let trackers = category.trackers.compactMap { tracker in
                    tracker.schedule.contains(dayOfWeek) ? tracker : nil
                }
                
                return trackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: trackers)
            }
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    func searchTextChangedTo(_ text: String?) {
        self.searchText = text
        visibleCategories = filtered(categories: categories)
    }
}

// MARK: - Trackers Data Source Provider

extension TrackersListViewModel: TrackersDataSourceProvider {
    func addRecordWithId(_ id: String) {
        let record = TrackerRecord(id: id, date: date)
        do {
            try dataProvider.createRecord(record)
        } catch {
            handleError(message: error.localizedDescription)
        }
        
        tracker = getTrackerWithId(id: id)
    }
    
    func removeRecordWithId(_ id: String) {
        let record = TrackerRecord(id: id, date: date)
        
        do {
            try dataProvider.deleteRecord(record)
        } catch {
            handleError(message: error.localizedDescription)
        }
        
        tracker = getTrackerWithId(id: id)
    }
    
    func cellIsMarkedWithId(_ id: String) -> Bool {
        let record = TrackerRecord(id: id, date: date)
        
        do {
            return try dataProvider.checkForExistence(record)
        } catch {
            handleError(message: error.localizedDescription)
            return false
        }
    }
    
    func daysAmountWithId(_ id: String) -> Int {
        do {
            return try dataProvider.readRecordAmountWith(id: id)
        } catch {
            handleError(message: error.localizedDescription)
            return 0
        }
    }
    
    func changeStateForTracker(_ tracker: Tracker) {
        guard date <= Date().onlyDate() else { return }
        if cellIsMarkedWithId(tracker.id) {
            removeRecordWithId(tracker.id)
        } else {
            addRecordWithId(tracker.id)
        }
    }
}

// MARK: - Error Handling

extension TrackersListViewModel: ErrorHandlerDelegate {
    func handleError(message: String) {
        headForError?(message)
    }
}
