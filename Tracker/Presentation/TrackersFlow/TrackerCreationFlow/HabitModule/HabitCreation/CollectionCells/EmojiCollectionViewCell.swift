//
//  TrackerTitleCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    static let identifier = "EmojiCell"

    var emoji: String? {
        didSet {
            emojiLabel.text = emoji
        }
    }
    
    var cellIsSelected: Bool = false {
        didSet {
            cellIsSelected ? (backgroundColor = .ypLightGray) : (backgroundColor = .clear)
        }
    }

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32)
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

private extension EmojiCollectionViewCell {
    func addSubviews() {
        addSubview(emojiLabel)
    }
    
    func configure() {
        layer.cornerRadius = 16
    }
    
    func applyLayout() {
        emojiLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(self)
        }
    }
}
