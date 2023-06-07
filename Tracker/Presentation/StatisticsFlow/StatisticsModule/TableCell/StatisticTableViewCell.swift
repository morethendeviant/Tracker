//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.06.2023.
//

import UIKit
import SnapKit

final class StatisticsTableViewCell: UITableViewCell {
    static let identifier = "StatisticsTableViewCell"
    
    var model: StatisticsModel? {
        didSet {
            guard let model else { return }
            numberLabel.text = numberFormatter.string(from: NSNumber(value: model.number))
            titleLabel.text = model.title
        }
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }()
    
    private var gradientColors: [UIColor] = [Asset.gradientRed.color,
                                             Asset.gradientGreen.color,
                                             Asset.gradientBlue.color]
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        configure()
        applyLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradient = UIImage.gradientImage(bounds: bounds, colors: gradientColors)
        contentView.layer.borderColor = UIColor(patternImage: gradient).cgColor
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews configure + layout

private extension StatisticsTableViewCell {
    func addSubviews() {
        contentView.addSubview(numberLabel)
        contentView.addSubview(titleLabel)
    }
    
    func configure() {
        backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
    }
    
    func applyLayout() {
        numberLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(contentView).inset(12)
            make.height.equalTo(41)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView).inset(12)
            make.height.equalTo(18)
        }
    }
}
