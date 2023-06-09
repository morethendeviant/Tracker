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
        self.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "hare.fill"), tag: 1)
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
        view.backgroundColor = .ypWhite
    }
    
    func applyLayout() {

    }
}
