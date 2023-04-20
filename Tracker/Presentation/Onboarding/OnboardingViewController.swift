//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 20.04.2023.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    private lazy var backgroundImage = UIImageView()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    init(style: OnboardingScreenStyle) {
        super.init(nibName: nil, bundle: nil)
        switch style {
        case .blue:
            backgroundImage.image = UIImage(named: "onboarding-blue")
            descriptionLabel.text = "Отслеживайте только то, что хотите"
        case .red:
            backgroundImage.image = UIImage(named: "onboarding-red")
            descriptionLabel.text = "Даже если это не литры води или йога"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        applyLayout()
    }
}

// MARK: - Nested Types

extension OnboardingViewController {
    enum OnboardingScreenStyle {
        case blue, red
    }
}

// MARK: - Subviews configure + layout

private extension OnboardingViewController {
    func addSubviews() {
        view.addSubview(backgroundImage)
        view.addSubview(descriptionLabel)
    }

    func applyLayout() {
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
