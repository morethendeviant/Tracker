//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit
import SnapKit

protocol TrackersViewCoordinatorProtocol: AnyObject {
    var headForTrackerSelect: (() -> Void)? { get set }
    var headForError: ((String) -> Void)? { get set }
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersStoreUpdate)
}

protocol ErrorHandlerDelegate: AnyObject {
    func handleError(message: String)
}

final class TrackersViewController: UIViewController, TrackersViewCoordinatorProtocol {
    var headForTrackerSelect: (() -> Void)?
    var headForError: ((String) -> Void)?
    
    private var dataProvider: DataProviderProtocol?
    private var date: Date {
        datePicker.date.onlyDate()
    }
    
    private var dayOfWeek: DayOfWeek {
        datePicker.date.getDayOfWeek()
    }
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus",
                            withConfiguration: UIImage.SymbolConfiguration (pointSize: 18, weight: .bold))
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
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 10
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return searchBar
    }()
        
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(nil, action: #selector(dateChanged), for: .valueChanged)
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        datePicker.calendar = calendar
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private lazy var contentPlaceholder = ContentPlaceholder(style: .trackers)

    private lazy var trackersCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collection.register(TrackersCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersCollectionHeaderView.identifier)
        collection.register(TrackersCollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TrackersCollectionFooterView.identifier)
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
        self.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "record.circle.fill"), tag: 0)
        
        self.dataProvider = {
            do {
                try dataProvider = DataProvider(weekday: dayOfWeek, delegate: self, errorHandlerDelegate: self)
                return dataProvider
            } catch {
                handleError(message: "Данные недоступны")
                return nil
            }
        }()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
        hideKeyboardWhenTappedAround()
    }
}

//MARK: - Search Bar Delegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getVisibleCategories()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        getVisibleCategories()
    }
}

//MARK: - Collection DataSource

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider?.numberOfItemsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            fatalError("cell not found")
        }
        
        guard let tracker = dataProvider?.tracker(at: indexPath) else { return UICollectionViewCell() }
        
        cell.color = Colors[tracker.color]
        cell.emoji = Emojis[tracker.emoji]
        cell.trackerText = tracker.name
        cell.callback = { [weak self] indexPath in
            guard let self, self.date <= Date().onlyDate() else { return }
            self.cellIsMarked(at: indexPath) ? self.removeRecord(at: indexPath) : self.addRecord(at: indexPath)
        }
        
        cell.isMarked = cellIsMarked(at: indexPath)
        cell.daysAmount = daysAmount(at: indexPath)
        cell.interaction = UIContextMenuInteraction(delegate: self)

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
        case UICollectionView.elementKindSectionFooter: id = TrackersCollectionFooterView.identifier
        default: id = ""
        }
        
        if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersCollectionHeaderView {
            view.titleLabel.text = dataProvider?.sectionName(indexPath.section)
            return view
        }
        
        if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersCollectionFooterView {
            return view
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: 62),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .required)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        section == (dataProvider?.numberOfSections ?? 1) - 1 ? CGSize(width: 0, height: 80) : CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

//MARK: - Collection View Delegate

extension TrackersViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfSections = dataProvider?.numberOfSections ?? 0
        if numberOfSections == 0 {
            trackersCollectionView.isHidden = true
            contentPlaceholder.isHidden = false
        } else {
            trackersCollectionView.isHidden = false
            contentPlaceholder.isHidden = true
        }
        return numberOfSections
    }
}

//MARK: - @objc

@objc private extension TrackersViewController {
    func plusButtonTapped() {
        searchBar.resignFirstResponder()
        headForTrackerSelect?()
    }
    
    func dateChanged() {
        dismiss(animated: false)
        getVisibleCategories()
    }
}

//MARK: - Private Methods

private extension TrackersViewController {
    func addRecord(at indexPath: IndexPath) {
        dataProvider?.addRecord(at: indexPath, for: date)
    }
    
    func removeRecord(at indexPath: IndexPath) {
        dataProvider?.deleteRecord(at: indexPath, for: date)
    }
    
    func cellIsMarked(at indexPath: IndexPath) -> Bool {
        guard let isMarked = dataProvider?.checkRecord(at: indexPath, for: date) else { return false }
        return isMarked
    }
    
    func daysAmount(at indexPath: IndexPath) -> Int {
        dataProvider?.recordsAmount(at: indexPath) ?? 0
    }

    func getVisibleCategories() {
        dataProvider?.getTrackers(name: searchBar.text, weekday: dayOfWeek)
        trackersCollectionView.reloadData()
    }
}

//MARK: - Data Provider Delegate
extension TrackersViewController: DataProviderDelegate {
    func didUpdate(_ update: TrackersStoreUpdate) {
        trackersCollectionView.performBatchUpdates {
            if let insertedIndexPath = update.insertedIndex {
                trackersCollectionView.insertItems(at: [insertedIndexPath])
            }

            if let insertedSection = update.insertedSection {
                trackersCollectionView.insertSections(insertedSection)
            }

            if let deletedIndexPath = update.deletedIndex {
                trackersCollectionView.deleteItems(at: [deletedIndexPath])
            }

            if let deletedSection = update.deletedSection {
                trackersCollectionView.deleteSections(deletedSection)
            }
            
            if let updatedIndexPath = update.updatedIndex {
                trackersCollectionView.reloadItems(at: [updatedIndexPath])
            }

            if let updatedSection = update.updatedSection {
                trackersCollectionView.reloadSections(updatedSection)
            }
        }
    }
}

//MARK: - Menu Interaction Delegate

extension TrackersViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let location = interaction.view?.convert(location, to: trackersCollectionView), let indexPath = trackersCollectionView.indexPathForItem(at: location) else { return UIContextMenuConfiguration() }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] actions -> UIMenu in
            let pin = UIAction(title: "Закрепить", image: UIImage(systemName: "pin")) { action in
                print("pin") //TODO: - Implement pin ability
            }
            
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { action in
                print("edit") //TODO: - Implement edit ability
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { action in
                self?.dataProvider?.deleteTracker(at: indexPath)
            }
            
            return UIMenu(children: [pin, edit, delete])
        }
        
        return configuration
    }
}

//MARK: - Subviews configure + layout

private extension TrackersViewController {
    func addSubviews() {
        view.addSubview(trackersCollectionView)
        view.addSubview(plusButton)
        view.addSubview(headerLabel)
        view.addSubview(datePicker)
        view.addSubview(searchBar)
        view.addSubview(contentPlaceholder)
        view.addSubview(filtersButton)
    }
    
    func configure() {
        view.backgroundColor = .ypWhite
    }
    
    func applyLayout() {
        plusButton.snp.makeConstraints { make in
            make.height.width.equalTo(19)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(13)
            make.leading.equalToSuperview().offset(18)
        }

        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(plusButton.snp.bottom).offset(13)
            make.leading.equalToSuperview().offset(16)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview()
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(plusButton.snp.bottom).offset(13)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(34)
        }

        trackersCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }

        filtersButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(130)
            make.trailing.equalToSuperview().offset(-130)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-17)
        }

        contentPlaceholder.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(230)
            make.width.equalToSuperview()
            make.height.equalTo(188)
        }
    }
}

extension TrackersViewController: ErrorHandlerDelegate {
    func handleError(message: String) {
        headForError?(message)
    }
}
