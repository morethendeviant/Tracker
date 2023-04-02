//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit

protocol TrackerCreationCoordinatorProtocol {
    var onHeadForHabit: (() -> Void)? { get set }
    var onHeadForEvent: (() -> Void)? { get set }
}

final class TrackerCreationViewController: BaseViewController, TrackerCreationCoordinatorProtocol {
    var onHeadForHabit: (() -> Void)?
    var onHeadForEvent: (() -> Void)?

    private var newHabit: BaseButton = {
        let button = BaseButton(style: .confirm, text: "Привычка")
        button.addTarget(nil, action: #selector(headForHabit), for: .touchUpInside)
        return button
    }()
    
    private var newEvent: BaseButton = {
        let button = BaseButton(style: .confirm, text: "Нерегулярное событие")
        button.addTarget(nil, action: #selector(headForEvent), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
    }
}

@objc private extension TrackerCreationViewController {
    func headForHabit() {
        onHeadForHabit?()
    }
    
    func headForEvent() {
        onHeadForEvent?()
    }
}





//MARK: - Subviews configure + layout
private extension TrackerCreationViewController {
    func addSubviews() {
        view.addSubview(newHabit)
        view.addSubview(newEvent)
    }
    
    func configure() {
        
    }
    
    func applyLayout() {
        newHabit.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(344)
            make.height.equalTo(60)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
        newEvent.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(newHabit.snp.bottom).offset(16)
            make.height.equalTo(60)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
    }
}
