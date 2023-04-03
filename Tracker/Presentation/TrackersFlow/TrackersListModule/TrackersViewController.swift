//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit
import SnapKit

protocol TrackersViewCoordinatorProtocol {
    var headForTrackerSelect: (() -> Void)? { get set }
}

final class TrackersViewController: UIViewController, TrackersViewCoordinatorProtocol {
    
    var headForTrackerSelect: (() -> Void)?
    
    private var categories: [TrackerCategory] = [ TrackerCategory(name: "Домашний уют", trackers: [Tracker(name: "Полить кота", color: 1, emoji: 2, schedule: [.mon, .tue])]),
                                                  TrackerCategory(name: "Радостные мелочи", trackers: [Tracker(name: "test3", color: 3, emoji: 4, schedule: [.fri, .sat]),
                                                                                                       Tracker(name: "Погладить кота", color: 4, emoji: 5, schedule: [.fri, .sun])])]
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            trackersCollectionView.isHidden = visibleCategories.isEmpty
            contentPlaceholder.isHidden = !visibleCategories.isEmpty
        }
    }
    
    private var completedTrackers: [TrackerRecord] = []
    
    private var date: String {
        datePicker.date.toString()
    }
    
    private var dayOfWeek: DayOfWeek {
        datePicker.date.getDayOfWeek()
    }
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(nil, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.delegate = self
        textField.layer.cornerRadius = 10
        textField.placeholder = "Поиск"
        return textField
    }()
        
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(nil, action: #selector(dateChanged), for: .valueChanged)
        
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private lazy var contentPlaceholder = ContentPlaceholder(style: .trackers)

    private lazy var trackersCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collection.register(TrackersCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersCollectionHeaderView.identifier)
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "record.circle.fill"), tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
        visibleCategories = getVisibleCategories()
    }
}


//MARK: - @objc
@objc private extension TrackersViewController {
    func plusButtonTapped() {
        headForTrackerSelect?()
    }
}

//MARK: - Text Field Delegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       visibleCategories = getVisibleCategories()
    }
}

//MARK: - Collection Flow Layout DataSource

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            fatalError("cell not found")
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        cell.color = .ypSelection(tracker.color)
        cell.emoji = Emojis[tracker.color]
        cell.trackerText = tracker.name
        cell.callback = { [weak self] in
            guard let self, date <= Date().toString() else { return }
            
            self.cellIsMarked(at: indexPath) ? self.removeRecord(at: indexPath) : self.addRecord(at: indexPath)
            self.trackersCollectionView.performBatchUpdates {
                self.trackersCollectionView.reloadItems(at: [indexPath])
            }
        }
        
        cell.isMarked = cellIsMarked(at: indexPath)
        cell.daysAmount = daysAmount(at: indexPath)
        return cell
    } 
}

//MARK: - Collection Flow Layout Delegate

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 167, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader: id = TrackersCollectionHeaderView.identifier
        default: id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersCollectionHeaderView else { return UICollectionReusableView()}
        view.titleLabel.text = visibleCategories[indexPath.section].name
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: 62),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .required)
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
}


//MARK: - Private Methods

extension TrackersViewController {
    func addRecord(at index: IndexPath) {
        let id = visibleCategories[index.section].trackers[index.item].id
        let trackerRecord = TrackerRecord(id: id, date: date)
        completedTrackers.append(trackerRecord)
    }
    
    func removeRecord(at index: IndexPath) {
        let id = visibleCategories[index.section].trackers[index.item].id
        completedTrackers.removeAll(where: { $0.id == id && $0.date == date } )
    }
    
    func cellIsMarked(at index: IndexPath) -> Bool {
        let id = visibleCategories[index.section].trackers[index.item].id
        return completedTrackers.filter( {$0.id == id && $0.date == date} ).count > 0
        
    }
    
    func daysAmount(at index: IndexPath) -> Int {
        let id = visibleCategories[index.section].trackers[index.item].id
        return completedTrackers.filter( {$0.id == id } ).count
    }
    
    @objc func dateChanged() {
        dismiss(animated: false)
        visibleCategories = getVisibleCategories()
        trackersCollectionView.reloadData()
    }
    
    func getVisibleCategories() -> [TrackerCategory] {
        categories.compactMap { category in
            var trackers = category.trackers.filter { $0.schedule.contains(dayOfWeek) }
            if let text = searchTextField.text, !text.isEmpty {
                trackers = trackers.filter { $0.name.lowercased().contains(text.lowercased()) }
            }
            return trackers.count > 0 ? TrackerCategory(name: category.name, trackers: trackers) : nil
        }
    }
}


//MARK: - Subviews configure + layout
private extension TrackersViewController {
    func addSubviews() {
        view.addSubview(plusButton)
        view.addSubview(headerLabel)
        view.addSubview(datePicker)
        view.addSubview(searchTextField)
        view.addSubview(contentPlaceholder)
        view.addSubview(trackersCollectionView)
        view.addSubview(filtersButton)
    }
    
    func configure() {
        view.backgroundColor = .ypWhite
        

    }
    
    func applyLayout() {
        plusButton.snp.makeConstraints { make in
            make.height.width.equalTo(19)
            
            make.top.equalTo(view.safeAreaLayoutGuide).offset(13)
            make.leading.equalTo(view).offset(18)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(plusButton.snp.bottom).offset(13)
            make.leading.equalTo(view).offset(16)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(7)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(plusButton.snp.bottom).offset(13)
            make.trailing.equalTo(view).offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(34)
        }
        
        
        
        trackersCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
            //make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.bottom.equalTo(view)
        }
        
        filtersButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.equalTo(view).offset(130)
            make.trailing.equalTo(view).offset(-130)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-17)
        }
        
        contentPlaceholder.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(searchTextField.snp.bottom).offset(230)
            make.width.equalTo(view)
            make.height.equalTo(188)
        }
    }
}
