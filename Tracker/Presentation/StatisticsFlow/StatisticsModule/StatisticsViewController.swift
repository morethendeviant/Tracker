//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
    
    private let viewModel: StatisticsViewModelProtocol
    
    private lazy var dataSource: StatisticsDiffableDataSource = {
        let dataSource = StatisticsDiffableDataSource(statisticsTableView)
        return dataSource
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistic", comment: "Statistic screen name")
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private lazy var statisticsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.allowsSelection = false
        table.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.identifier)
        return table
    }()
    
    private lazy var contentPlaceholder = ContentPlaceholder(style: .statistics)
    
    init(viewModel: StatisticsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        let tabBarItemText = NSLocalizedString("statistics", comment: "Statistics tab bar text")
        self.tabBarItem = UITabBarItem(title: tabBarItemText, image: Asset.hareFill.image, tag: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
        statisticsTableView.dataSource = dataSource
        setupBindings()
        viewModel.viewDidLoad()
    }
}

// MARK: - Table View Delegate

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

// MARK: - Private Methods

private extension StatisticsViewController {
    func setupBindings() {
        viewModel.statistics
            .sink { [weak self] statistics in
                if statistics.isEmpty {
                    self?.statisticsTableView.isHidden = true
                    self?.contentPlaceholder.isHidden = false
                } else {
                    self?.statisticsTableView.isHidden = false
                    self?.contentPlaceholder.isHidden = true
                    self?.dataSource.reload(statistics)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Subviews configure + layout

private extension StatisticsViewController {
    func addSubviews() {
        view.addSubview(headerLabel)
        view.addSubview(statisticsTableView)
        view.addSubview(contentPlaceholder)
    }
    
    func configure() {
        view.backgroundColor = Asset.ypWhite.color
    }
    
    func applyLayout() {
        headerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(52)
            make.height.equalTo(41)
        }
        
        statisticsTableView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(headerLabel.snp.bottom).offset(77)
            make.bottom.equalTo(view)
        }
        
        contentPlaceholder.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
        }
    }
}
