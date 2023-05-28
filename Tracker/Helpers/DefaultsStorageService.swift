//
//  DefaultsStorageService.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 28.05.2023.
//

import Foundation

final class DefaultsStorageService {
    var onboardingWasShown: Bool {
        get {
            UserDefaults.standard.bool(forKey: "onboarding")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "onboarding")
        }
    }
}
