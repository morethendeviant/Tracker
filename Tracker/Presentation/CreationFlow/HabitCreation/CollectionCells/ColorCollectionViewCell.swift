//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 31.03.2023.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    private let mainLayer: CALayer = {
        let layer = CALayer()
        
        layer.cornerRadius = 8
        
        return layer
    }()
    
    private let borderLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.cornerRadius = 14
        layer.borderWidth = 3
        layer.borderColor = UIColor.clear.cgColor
        return layer
    }()
    
    
    
    var color: UIColor? {
        didSet {
            //backgroundColor = color
            mainLayer.backgroundColor = color?.cgColor
        }
    }
    
    var cellIsSelected: Bool = false {
        didSet {
            cellIsSelected ? (borderLayer.borderColor = UIColor.ypLightGray?.cgColor) : (borderLayer.borderColor = UIColor.clear.cgColor)
        }
    }
    
//    override var isSelected: Bool {
//        didSet {
//            isSelected ? (borderLayer.borderColor = UIColor.ypLightGray?.cgColor) : (borderLayer.borderColor = UIColor.clear.cgColor)
//
//        }
//    }
    
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
        layer.addSublayer(borderLayer)
        layer.addSublayer(mainLayer)
    }
    
    func configure() {
        
//        layer.borderColor = UIColor.ypWhite?.cgColor
//        layer.borderWidth = 6
//        layer.cornerRadius = 1
        
//        layer.cornerRadius = 8
//        layer.borderWidth = 3
//        layer.borderColor = UIColor.clear.cgColor
    }
    
    func applyLayout() {
        mainLayer.frame = CGRect(x: 6, y: 6, width: bounds.size.width - 12, height: bounds.size.height - 12)
        borderLayer.frame = bounds
        
    }
}
