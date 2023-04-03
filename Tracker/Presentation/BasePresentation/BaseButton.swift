//
//  BaseButton.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 28.03.2023.
//

import UIKit

class BaseButton: UIButton {
    
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

extension BaseButton {
    func setUpAppearance(for style: Style) {
        switch style {
        case .confirm:
            backgroundColor = .ypBlack
            setTitleColor(.ypWhite, for: .normal)
            isEnabled = true
        case .disabled:
            backgroundColor = .ypGray
            setTitleColor(.ypWhite, for: .normal)
            isEnabled = false
        case .cancel:
            backgroundColor = .ypWhite
            setTitleColor(.ypRed, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.ypRed?.cgColor
            isEnabled = true
        }
    }
}

extension BaseButton {
    enum Style {
        case disabled, confirm, cancel
    }
}
