//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 28.03.2023.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    var color: UIColor? {
        didSet {
            colorBackgroundView.backgroundColor = color
            plusButton.backgroundColor = color
        }
    }
    
    var emoji: String? {
        didSet {
            emojiLabel.text = emoji
        }
    }
    
    var trackerText: String? {
        didSet {
            trackerLabel.text = trackerText
        }
    }
    
    var daysAmount: Int? {
        didSet {
            if let daysAmount {
                var suffix: String
                let lastDigit = daysAmount % 10
                
                switch lastDigit {
                case 1: suffix = "день"
                case 2, 3, 4: suffix = "дня"
                case 5, 6, 7, 8, 9 , 0: suffix = "дней"
                default: suffix = ""
                }
                daysCounter.text = "\(daysAmount) " + suffix
            }
        }
    }
    
    var callback: (() -> Void)?
    
    private let colorBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
 
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
        label.layer.cornerRadius = 12
        label.textAlignment = .center
        return label
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypWhite
        return label
    }()
    
    private let daysCounter: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 17
        button.tintColor = .ypWhite
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        button.addTarget(nil, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubviews()
        applyLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func plusButtonTapped() {
        callback?()
        plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        plusButton.backgroundColor = color?.withAlphaComponent(0.3)
    }
}

//MARK: - Subviews configure + layout
private extension TrackerCollectionViewCell {
    func addSubviews() {
        addSubview(colorBackgroundView)
        addSubview(emojiLabel)
        addSubview(trackerLabel)
        addSubview(daysCounter)
        addSubview(plusButton)
    }
    
    func configure() {
        
    }
    
    func applyLayout() {
        colorBackgroundView.snp.makeConstraints { make in
            make.height.equalTo(90)
            make.top.leading.trailing.equalTo(self)
        }
        
        emojiLabel.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.equalTo(self.snp.top).offset(12)
            make.leading.equalTo(self.snp.leading).offset(12)
        }
        
        trackerLabel.snp.makeConstraints { make in
            make.leading.equalTo(colorBackgroundView).offset(12)
            make.trailing.bottom.equalTo(colorBackgroundView).offset(-12)
        }
        
        plusButton.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.trailing.equalTo(self).offset(-12)
            make.bottom.equalTo(self)
        }
        
        daysCounter.snp.makeConstraints { make in
            make.centerY.equalTo(plusButton)
            make.leading.equalTo(self).offset(12)
        }
    }
}
