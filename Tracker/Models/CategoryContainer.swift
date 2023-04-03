//
//  CategoryContainer.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 03.04.2023.
//

import Foundation

struct CategoryContainer {
    static let shared = CategoryContainer()
    
    var items: [String] = ["Важное", "Очень важное", "Совсем не важное"]
}
