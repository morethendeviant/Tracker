//
//  UIColor + Ext.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit

extension UIColor {
    static var ypBlack: UIColor? { UIColor(named: "ypBlack") }
    static var ypWhite: UIColor? { UIColor(named: "ypWhite") }
    static var ypGray: UIColor? { UIColor(named: "ypGray") }
    static var ypLightGray: UIColor? { UIColor(named: "ypLightGray") }
    static var ypBackground: UIColor? { UIColor(named: "ypBackground") }
    static var ypRed: UIColor? { UIColor(named: "ypRed") }
    static var ypBlue: UIColor? { UIColor(named: "ypBlue") }
    
    static func ypSelection(_ number: Int) -> UIColor? { UIColor(named: "ypSelection\(number)") }   
}
