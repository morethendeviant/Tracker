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
        label.textColor = Asset.ypBlack.color
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

// MARK: - Private methods
 
extension ContentPlaceholder {
    func setUpContent(with style: Style) {
        switch style {
        case .trackers:
            imageView.image = Asset.star.image
            label.text = NSLocalizedString("emptyPlaceholder.trackers", comment: "Text displayed on empty schedule")
            
        case .category: break
        case .search:
            imageView.image = Asset.notFound.image
            label.text = NSLocalizedString("emptyPlaceholder.search", comment: "Text displayed on empty search")
        case .statistics:
            imageView.image = Asset.statistics.image
            label.text = NSLocalizedString("emptyPlaceholder.statistics", comment: "Text displayed on empty statistics")
        }
    }
}

// MARK: - Subviews configure + layout
private extension ContentPlaceholder {
    func addSubviews() {
        addSubview(imageView)
        addSubview(label)
    }

    func applyLayout() {
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.equalTo(self)
            make.top.equalTo(self)
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
