//
//  PlusMinusButton.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 07.06.2023.
//

import UIKit
import SnapKit

final class PlusMinusButton: UIButton {
    
    private let mode: PlusMinusButtonMode
    
    init(mode: PlusMinusButtonMode) {
        self.mode = mode
        super.init(frame: .zero)
        configure()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews configure + layout

private extension PlusMinusButton {

    func configure() {
        backgroundColor = Asset.ypSelection2.color
        let buttonImage = UIImage(systemName: mode.rawValue,
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        setImage(buttonImage, for: .normal)
        tintColor = Asset.ypWhite.color
        layer.cornerRadius = 17
    }
    
    func applyLayout() {
        self.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width)
        }
    }
}

enum PlusMinusButtonMode: String {
    case plus
    case minus
}
