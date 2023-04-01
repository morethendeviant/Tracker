//
//  CollectionHeaderView.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 31.03.2023.
//

import UIKit

final class CollectionHeaderView: UICollectionReusableView {
    
    static let identifier = "CreationHeader"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configure()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Subviews configure + layout
private extension CollectionHeaderView {
    func addSubviews() {
        addSubview(titleLabel)
    }
    
    func configure() {
        
    }
    
    func applyLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.equalTo(self).offset(10)
            
        }
    }
}
