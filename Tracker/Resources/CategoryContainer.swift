//
//  CategoryContainer.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 03.04.2023.
//

import Foundation

final class CategoryContainer {
    
    static let shared = CategoryContainer()
    
    private(set) var items: [String] = ["Важное", "Очень важное", "Совсем не важное", "Домашние дела"]
    
    func addCategory(_ category: String) {
        items.append(category)
    }
}
