//
//  TrackersCollectionHeaderView.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import UIKit

final class TrackersCollectionHeaderView: UICollectionReusableView {
    
    static let identifier = "CategoriesHeader"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews configure + layout

private extension TrackersCollectionHeaderView {
    func addSubviews() {
        addSubview(titleLabel)
    }

    func applyLayout() {
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self).inset(12)
            make.leading.equalTo(self).inset(12)
        }
    }
}
