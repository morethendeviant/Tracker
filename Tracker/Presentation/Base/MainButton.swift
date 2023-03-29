//
//  MainButton.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 28.03.2023.
//

import UIKit

class MainButton: UIButton {
        
    private let label: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 16
        return label
    }()
    
    init(style: Style) {
        super.init(frame: .zero)
        setUp(style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainButton {
    func setUp(_ style: Style) {
        switch style {
        case .default:
            label.backgroundColor = .ypBlack
            label.textColor = .ypWhite
            
        case .disabled:
            label.backgroundColor = .ypGray
            label.textColor = .ypWhite
        case .cancel:
            label.backgroundColor = .ypWhite
            label.textColor = .ypRed
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.ypRed?.cgColor
        }
    }
}

extension MainButton {
    enum Style {
        case disabled, `default`, cancel
    }
}
