//
//  Emojis.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import Foundation

struct Emojis {
    private static let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    static subscript(_ index: Int) -> String? {
        guard 0..<emojis.count ~= index else { return nil }
        
        return emojis[index]
    }
    
    static var count: Int {
        emojis.count
    }
}
