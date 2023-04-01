//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 31.03.2023.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    
    
    var color: UIColor? {
        didSet {
            backgroundColor = color
        }
    }
    
    var cellIsSelected: Bool = false {
        didSet {
            cellIsSelected ? (layer.borderColor = UIColor.ypLightGray?.cgColor) : (layer.borderColor = UIColor.clear.cgColor)
        }
    }
    
    private lazy var colorLabel: UIView = {
        let label = UIView()
        
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
private extension ColorCollectionViewCell {
    func addSubviews() {
        
    }
    
    func configure() {
        layer.cornerRadius = 8
        layer.borderWidth = 3
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func applyLayout() {

    }
}
