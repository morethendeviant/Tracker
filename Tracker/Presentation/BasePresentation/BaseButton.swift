//
//  BaseButton.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 28.03.2023.
//

import UIKit

final class BaseButton: UIButton {
    
    init(style: Style, text: String) {
        super.init(frame: .zero)
        setUpAppearance(for: style)
        layer.cornerRadius = 16
        setTitle(text, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Appearance

extension BaseButton {
    func setUpAppearance(for style: Style) {
        switch style {
        case .confirm:
            backgroundColor = Asset.ypBlack.color
            setTitleColor(Asset.ypWhite.color, for: .normal)
            isEnabled = true
        case .disabled:
            backgroundColor = Asset.ypGray.color
            setTitleColor(Asset.ypWhite.color, for: .normal)
            isEnabled = false
        case .cancel:
            backgroundColor = Asset.ypWhite.color
            setTitleColor(Asset.ypRed.color, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = Asset.ypRed.color.cgColor
            isEnabled = true
        }
    }
}

// MARK: - Style Enum

extension BaseButton {
    enum Style {
        case disabled, confirm, cancel
    }
}
