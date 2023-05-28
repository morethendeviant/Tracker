//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
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
