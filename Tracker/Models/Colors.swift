//
//  Colors.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

struct Colors {
    private static let colors = Array(0...17).map { "ypSelection\($0 + 1)" }
    
    static subscript(_ index: Int) -> String? {
        guard 0..<colors.count ~= index else { return nil }
        return colors[index]
    }
    
    static var count: Int {
        colors.count
    }
}
