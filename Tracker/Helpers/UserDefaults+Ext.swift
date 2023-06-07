//
//  UserDefaults+Ext.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 22.05.2023.
//

import Foundation

extension UserDefaults {
    @objc dynamic var onboarding: Bool {
        return bool(forKey: "onboarding")
    }
}
