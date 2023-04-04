//
//  CollectionHeaderView.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 31.03.2023.
//

import UIKit

final class HabitCollectionHeaderView: UICollectionReusableView {
    
    static let identifier = "CreationHeader"
    
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

//MARK: - Subviews configure + layout

private extension HabitCollectionHeaderView {
    func addSubviews() {
        addSubview(titleLabel)
    }
    
    func applyLayout() {
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self)
            make.leading.equalTo(self).offset(10)
            
        }
    }
}
