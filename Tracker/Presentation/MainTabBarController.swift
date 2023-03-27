//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension MainTabBarController {
    func configure() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.ypBlack
        tabBar.standardAppearance = tabBarAppearance
        tabBar.tintColor = UIColor.ypWhite
    }
}
