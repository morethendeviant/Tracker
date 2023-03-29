//
//  StubView.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit

class StubView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ypBlue
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
