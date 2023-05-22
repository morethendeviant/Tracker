//
//  HabitCreationViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 23.04.2023.
//

import Foundation

protocol HabitCreationCoordination: AnyObject {
    var onCancel: (() -> Void)? { get set }
    var onCreate: (() -> Void)? { get set }
    var onHeadForCategory: ((String?) -> Void)? { get set }
    var onHeadForSchedule: (([DayOfWeek]) -> Void)? { get set }
    var headForError: ((String) -> Void)? { get set }
    
    func selectCategory(_ category: String?)
    func returnWithWeekdays(_ days: [DayOfWeek])
}

protocol EventCreationCoordination: AnyObject {
    var onCancel: (() -> Void)? { get set }
    var onCreate: (() -> Void)? { get set }
    var onHeadForCategory: ((String?) -> Void)? { get set }
    var headForError: ((String) -> Void)? { get set }
    
    func selectCategory(_ category: String?)
}

protocol HabitCreationViewModelProtocol {
    var confirmEnabled: Bool { get }
    var confirmEnabledObserver: Observable<Bool> { get }
    
    var weekdays: [DayOfWeek] { get }
    var weekdaysObserver: Observable<[DayOfWeek]> { get }
    
    var selectedCategory: String? { get }
    var selectedCategoryObserver: Observable<String?> { get }
    
    var tableContent: [CellContent] { get }
    
    var emojiSelectedItem: Int? { get }
    var colorSelectedItem: Int? { get }
    
    func setTitle(_ title: String)
    func setColor(_ index: Int)
    func setEmoji(_ index: Int)
    
    func cancelButtonTapped()
    func createButtonTapped()
    func scheduleCallTapped()
    func categoryCellTapped()
}

final class HabitCreationViewModel {
    var onCancel: (() -> Void)?
    var onCreate: (() -> Void)?
    var onHeadForCategory: ((String?) -> Void)?
    var onHeadForSchedule: (([DayOfWeek]) -> Void)?
    var headForError: ((String) -> Void)?
    
    private let dataStore: TrackerCreationDataStoreProtocol
    
    private(set) var tableContent: [CellContent]
    private var tableDataModel: TrackerCreationTableModel

    @Observable var confirmEnabled: Bool = false
    @Observable var selectedCategory: String? {
        didSet {
            checkForConfirm()
        }
    }
    
    @Observable var weekdays: [DayOfWeek] = [] {
        didSet {
            checkForConfirm()
        }
    }
    
    private var trackerTitle: String? {
        didSet {
            checkForConfirm()
        }
    }
    private(set) var emojiSelectedItem: Int? {
        didSet {
            checkForConfirm()
        }
    }
    
    private(set) var colorSelectedItem: Int? {
        didSet {
            checkForConfirm()
        }
    }

    private var tracker: Tracker?
    
    init(dataStore: TrackerCreationDataStoreProtocol, tableDataModel: TrackerCreationTableModel) {
        self.dataStore = dataStore
        self.tableDataModel = tableDataModel
        self.tableContent = tableDataModel.tableContent()
        if case .event = tableDataModel {
            weekdays = DayOfWeek.allCases
        }
    }
    
    func checkForConfirm() {
        if let text = trackerTitle, !text.isEmpty,
           let colorSelectedItem,
           let emojiSelectedItem,
           selectedCategory != nil,
           !weekdays.isEmpty {
            
            switch tableDataModel {
            case .event:
                tracker = Tracker(name: text, color: colorSelectedItem, emoji: emojiSelectedItem, schedule: weekdays)
            case .habit:
                tracker = Tracker(name: text, color: colorSelectedItem, emoji: emojiSelectedItem, schedule: weekdays)
            }
            
            confirmEnabled = true
        } else {
            tracker = nil
            confirmEnabled = false
        }
    }
}

extension HabitCreationViewModel: HabitCreationViewModelProtocol {
    var weekdaysObserver: Observable<[DayOfWeek]> {
        $weekdays
    }
    
    var selectedCategoryObserver: Observable<String?> {
        $selectedCategory
    }
    
    var confirmEnabledObserver: Observable<Bool> {
        $confirmEnabled
    }
    
    func setTitle(_ title: String) {
        trackerTitle = title
    }
    
    func setColor(_ index: Int) {
        colorSelectedItem = index
    }
    
    func setEmoji(_ index: Int) {
        emojiSelectedItem = index
    }
    
    func scheduleCallTapped() {
        onHeadForSchedule?(weekdays)
    }
    
    func categoryCellTapped() {
        onHeadForCategory?(selectedCategory)
    }
    
    func createButtonTapped() {
        guard let tracker, let selectedCategory else { return }
        do {
            try dataStore.createTracker(tracker, categoryName: selectedCategory)
            onCreate?()
        } catch {
            headForError?(error.localizedDescription)
        }
    }
    
    func cancelButtonTapped() {
        onCancel?()
    }
}

extension HabitCreationViewModel: HabitCreationCoordination {
    func selectCategory(_ category: String?) {
        self.tableContent[0] = CellContent(text: self.tableContent[0].text, detailText: category)
        selectedCategory = category
    }
    
    func returnWithWeekdays(_ weekDays: [DayOfWeek]) {
        let weekdaysText = DayOfWeek.shortNamesFor(weekDays)
        if !weekDays.isEmpty, case .habit = tableDataModel {
            self.tableContent[1] = CellContent(text: self.tableContent[1].text, detailText: weekdaysText)
            weekdays = weekDays
        }
    }
}

extension HabitCreationViewModel: EventCreationCoordination {
}

// MARK: - Error Handling

extension HabitCreationViewModel: ErrorHandlerDelegate {
    func handleError(message: String) {
        headForError?(message)
    }
}
