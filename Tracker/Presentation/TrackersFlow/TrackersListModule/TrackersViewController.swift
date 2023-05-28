//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit
import SnapKit

final class TrackersViewController: UIViewController {
    
    private let viewModel: TrackersListViewModelProtocol
    private let diffableDataSourceProvider: TrackersDataSourceProvider
    
    private lazy var diffableDataSource: TrackerListDiffableDataSource = {
        let dataSource = TrackerListDiffableDataSource(trackersCollectionView,
                                                       dataSourceProvider: diffableDataSourceProvider,
                                                       interactionDelegate: self)
        return dataSource
    }()
    
    private var date: Date {
        datePicker.date.onlyDate()
    }
    
    private var dayOfWeek: DayOfWeek {
        datePicker.date.getDayOfWeek()
    }
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        button.setImage(image, for: .normal)
        button.tintColor = Asset.ypBlack.color
        button.addTarget(nil, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers", comment: "Trackers screen name")
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 10
        searchBar.placeholder = NSLocalizedString("search", comment: "Search bar placeholder text")
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
        datePicker.locale = .autoupdatingCurrent
        datePicker.calendar = .autoupdatingCurrent
        datePicker.datePickerMode = .date
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.backgroundColor = Asset.ypWhite.color
        return datePicker
    }()
    
    private lazy var contentPlaceholder = ContentPlaceholder(style: .trackers)
    
    private lazy var trackersCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.backgroundColor = Asset.ypWhite.color
        collection.register(TrackerCollectionViewCell.self,
                            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        collection.register(TrackersCollectionHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: TrackersCollectionHeaderView.identifier)
        
        collection.register(TrackersCollectionFooterView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                            withReuseIdentifier: TrackersCollectionFooterView.identifier)
        
        return collection
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.setTitleColor(.white, for: .normal)
        let buttonTitle = NSLocalizedString("filters", comment: "Filters button text")
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = Asset.ypBlue.color
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()
    
    init(viewModel: TrackersListViewModelProtocol, diffableDataSourceProvider: TrackersDataSourceProvider) {
        self.viewModel = viewModel
        self.diffableDataSourceProvider = diffableDataSourceProvider
        super.init(nibName: nil, bundle: nil)
        let tabBarItemText = NSLocalizedString("trackers", comment: "Trackers tab bar text")
        self.tabBarItem = UITabBarItem(title: tabBarItemText, image: Asset.recordCircleFill.image, tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
        trackersCollectionView.dataSource = diffableDataSource
        setSupplementaryDataViewProvider()
        hideKeyboardWhenTappedAround()
        setUpBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.dateChangedTo(datePicker.date)
    }
}

// MARK: - @objc

@objc private extension TrackersViewController {
    func plusButtonTapped() {
        searchBar.resignFirstResponder()
        viewModel.plusButtonTapped()
    }
    
    func dateChanged() {
        dismiss(animated: false)
        viewModel.dateChangedTo(datePicker.date)
    }
}

// MARK: - Private Methods

private extension TrackersViewController {
    func setSupplementaryDataViewProvider() {
        diffableDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            var id: String
            switch kind {
            case UICollectionView.elementKindSectionHeader: id = TrackersCollectionHeaderView.identifier
            case UICollectionView.elementKindSectionFooter: id = TrackersCollectionFooterView.identifier
            default: id = ""
            }
            
            if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersCollectionHeaderView {
                view.titleLabel.text = self?.viewModel.sectionNameAt(indexPath.section)
                return view
            }
            
            if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersCollectionFooterView {
                return view
            }
            
            return UICollectionReusableView()
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(148))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .flexible(10)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        
        let regularSection = NSCollectionLayoutSection(group: group)
        regularSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(32))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        
        regularSection.boundarySupplementaryItems = [header]
        
        let lastSection = NSCollectionLayoutSection(group: group)
        lastSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(80))
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                 elementKind: UICollectionView.elementKindSectionFooter,
                                                                 alignment: .bottomLeading)
        
        lastSection.boundarySupplementaryItems = [header, footer]
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            if sectionIndex == self?.viewModel.lastSectionIndex {
                return lastSection
            } else {
                return regularSection
            }
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        
        layout.configuration = config
        return layout
    }
    
    func setUpBindings() {
        viewModel.visibleCategoriesObserver.bind { [weak self] categories in
            guard let self else { return }
            
            self.diffableDataSource.reloadAll(categories)
            
            if let text = self.searchBar.text, !text.isEmpty {
                self.contentPlaceholder.setUpContent(with: .search)
            } else {
                self.contentPlaceholder.setUpContent(with: .trackers)
            }
            
            self.contentPlaceholder.isHidden = !categories.isEmpty
        }
        
        viewModel.trackerObserver.bind { [weak self] tracker in
            guard let tracker else { return }
            self?.diffableDataSource.reloadTracker(tracker)
        }
    }
}

// MARK: - Search Bar Delegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTextChangedTo(searchText)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        viewModel.searchTextChangedTo(nil)
    }
}

// MARK: - Menu Interaction Delegate

extension TrackersViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let location = interaction.view?.convert(location, to: trackersCollectionView),
              let indexPath = trackersCollectionView.indexPathForItem(at: location)
        else {
            return UIContextMenuConfiguration()
        }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu in
            let pinItemText = NSLocalizedString("pin", comment: "Pin menu item text")
            let pin = UIAction(title: pinItemText, image: UIImage(systemName: "pin")) { _ in
                // TODO: - Implement pin ability
            }
            
            let editItemText = NSLocalizedString("edit", comment: "Edit menu item text")
            let edit = UIAction(title: editItemText, image: UIImage(systemName: "pencil")) { _ in
                // TODO: - Implement edit ability
            }
            
            let deleteItemText = NSLocalizedString("delete", comment: "Delete menu item text")
            let delete = UIAction(title: deleteItemText, image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                self?.viewModel.deleteTrackerAt(indexPath: indexPath)
            }
            
            return UIMenu(children: [pin, edit, delete])
        }
        
        return configuration
    }
}

// MARK: - Subviews configure + layout

private extension TrackersViewController {
    func addSubviews() {
        view.addSubview(trackersCollectionView)
        view.addSubview(plusButton)
        view.addSubview(headerLabel)
        view.addSubview(datePicker)
        view.addSubview(searchBar)
        trackersCollectionView.addSubview(contentPlaceholder)
        view.addSubview(filtersButton)
    }
    
    func configure() {
        view.backgroundColor = Asset.ypWhite.color
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
            make.width.equalTo(100).priority(250)
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
            make.centerY.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(188)
        }
    }
}
