//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit

final class TrackersViewController: UIViewController {


    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "record.circle.fill"), tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}

