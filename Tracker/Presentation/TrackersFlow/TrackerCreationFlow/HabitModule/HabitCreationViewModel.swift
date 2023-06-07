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
    
    var trackerViewModel: TrackerViewModel? { get }
    var trackerViewModelObserver: Observable<TrackerViewModel?> { get }
    
    var screenContent: HabitScreenContent { get }
    var tableDataModel: TrackerCreationTableModel { get }
    
    var emojiSelectedItem: Int? { get }
    var colorSelectedItem: Int? { get }
    
    func setTitle(_ title: String)
    func setColor(_ index: Int)
    func setEmoji(_ index: Int)
    
    func viewDidLoad()
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
    
    private(set) var screenContent: HabitScreenContent
    private(set) var tableDataModel: TrackerCreationTableModel
    
    @Observable var trackerViewModel: TrackerViewModel?
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
    
    private var storingTracker: Tracker?
    
    init(dataStore: TrackerCreationDataStoreProtocol, tableDataModel: TrackerCreationTableModel) {
        self.dataStore = dataStore
        self.tableDataModel = tableDataModel
        self.screenContent = tableDataModel.tableContent()
    }
    
    func checkForConfirm() {
        if let text = trackerTitle, !text.isEmpty,
           let colorSelectedItem,
           let emojiSelectedItem,
           selectedCategory != nil,
           !weekdays.isEmpty {
            
            switch tableDataModel {
            case .event(let tracker):
                let id = tracker?.id
                storingTracker = Tracker(id: id,
                                         name: text,
                                         color: colorSelectedItem,
                                         emoji: emojiSelectedItem,
                                         schedule: weekdays)
            case .habit(let tracker):
                let id = tracker?.id
                storingTracker = Tracker(id: id,
                                         name: text,
                                         color: colorSelectedItem,
                                         emoji: emojiSelectedItem,
                                         schedule: weekdays)
            }
            
            confirmEnabled = true
        } else {
            storingTracker = nil
            confirmEnabled = false
        }
    }
}

extension HabitCreationViewModel: HabitCreationViewModelProtocol {
    func viewDidLoad() {
        switch tableDataModel {
        case .event(let tracker):
            weekdays = DayOfWeek.allCases
            guard let tracker else { return }
            
            selectedCategory = tracker.category
            trackerTitle = tracker.name
            emojiSelectedItem = tracker.emoji
            colorSelectedItem = tracker.color
            trackerViewModel = tracker
            
        case .habit(let tracker):
            guard let tracker else { return }
            
            selectedCategory = tracker.category
            trackerTitle = tracker.name
            emojiSelectedItem = tracker.emoji
            colorSelectedItem = tracker.color
            weekdays = tracker.schedule
            trackerViewModel = tracker
        }
    }
    
    var trackerViewModelObserver: Observable<TrackerViewModel?> {
        $trackerViewModel
    }
    
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
        guard let storingTracker, let selectedCategory else { return }
        do {
            try dataStore.createTracker(storingTracker, categoryName: selectedCategory)
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
        screenContent = HabitScreenContent(daysAmount: screenContent.daysAmount,
                                           trackerName: screenContent.trackerName,
                                           categoryName: category,
                                           scheduleText: screenContent.scheduleText,
                                           emoji: screenContent.emoji,
                                           color: screenContent.color,
                                           categoryCellName: screenContent.categoryCellName,
                                           scheduleCellName: screenContent.scheduleCellName)
        selectedCategory = category
    }
    
    func returnWithWeekdays(_ weekDays: [DayOfWeek]) {
        let weekdaysText = DayOfWeek.shortNamesFor(weekDays)
        if !weekDays.isEmpty, case .habit = tableDataModel {
            screenContent = HabitScreenContent(daysAmount: screenContent.daysAmount,
                                               trackerName: screenContent.trackerName,
                                               categoryName: screenContent.categoryName,
                                               scheduleText: weekdaysText,
                                               emoji: screenContent.emoji,
                                               color: screenContent.color,
                                               categoryCellName: screenContent.categoryCellName,
                                               scheduleCellName: screenContent.scheduleCellName)
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
