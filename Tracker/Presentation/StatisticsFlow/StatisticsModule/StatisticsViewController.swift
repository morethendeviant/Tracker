//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private lazy var statisticTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.isScrollEnabled = true
        table.backgroundColor = Asset.ypWhite.color
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        return table
    }()
    
    
    init() {
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
    }
}


extension StatisticsViewController: UITableViewDelegate {
    
}

// MARK: - Subviews configure + layout
private extension StatisticsViewController {
    func addSubviews() {
        
    }
    
    func configure() {
        view.backgroundColor = Asset.ypWhite.color
    }
    
    func applyLayout() {

    }
}
