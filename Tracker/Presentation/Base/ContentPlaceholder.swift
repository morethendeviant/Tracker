//
//  ContentPlaceholder.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 28.03.2023.
//

import UIKit
import SnapKit

final class ContentPlaceholder: UIView {

    private let imageView = UIImageView()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        return label
    }()
    
    init(style: Style) {
        super.init(frame: .zero)
        setUpContent(with: style)
        addSubviews()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

private extension ContentPlaceholder {
    func setUpContent(with style: Style) {
        switch style {
        case .trackers:
            imageView.image = UIImage(named: "star")
            label.text = "Что будем отслеживать?"
            
        case .category: break
        case .search: break
        case .statistics: break
        }
    }
    
}

//MARK: - Subviews configure + layout
private extension ContentPlaceholder {
    func addSubviews() {
        addSubview(imageView)
        addSubview(label)
    }
    
    func configure() {
        
    }
    
    func applyLayout() {
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.equalTo(self)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalTo(self)
        }
        
        
    }
}


extension ContentPlaceholder {
    enum Style {
        case trackers, category, search, statistics
    }
}
