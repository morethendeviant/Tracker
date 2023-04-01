//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit
import SnapKit

final class TrackersViewController: UIViewController {
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.tintColor = .ypBlack
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
        textField.layer.cornerRadius = 10
        textField.placeholder = "Поиск"

        return textField
    }()
        
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
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
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            fatalError("cell not found")
        }
        cell.color = .ypSelection(1)
        cell.emoji = "😍"
        cell.trackerText = "Поливать растения"
        cell.callback = { [weak self] in
            
            
            self?.trackersCollectionView.performBatchUpdates {
                self?.trackersCollectionView.reloadItems(at: [indexPath])
            }
        }
        
        cell.isMarked = true
        cell.daysAmount = 115
        return cell
    }
    
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 167, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    
}

//MARK: - Subviews configure + layout
private extension TrackersViewController {
    func addSubviews() {
        view.addSubview(plusButton)
        view.addSubview(headerLabel)
        view.addSubview(datePicker)
        view.addSubview(searchTextField)
        //view.addSubview(contentPlaceholder)
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
        
//        contentPlaceholder.snp.makeConstraints { make in
//            make.centerX.equalTo(view)
//            make.top.equalTo(searchTextField.snp.bottom).offset(230)
//            make.width.equalTo(view)
//            make.height.equalTo(188)
//        }
        
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
    }
}
