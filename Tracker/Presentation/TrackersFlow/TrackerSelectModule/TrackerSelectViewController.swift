//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit

protocol TrackerSelectCoordinatorProtocol {
    var onHeadForHabit: (() -> Void)? { get set }
    var onHeadForEvent: (() -> Void)? { get set }
}

final class TrackerSelectViewController: BaseViewController, TrackerSelectCoordinatorProtocol {
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
        applyLayout()
    }
}

// MARK: - @objc

@objc private extension TrackerSelectViewController {
    func headForHabit() {
        onHeadForHabit?()
    }
    
    func headForEvent() {
        onHeadForEvent?()
    }
}

// MARK: - Subviews configure + layout

private extension TrackerSelectViewController {
    func addSubviews() {
        view.addSubview(newHabit)
        view.addSubview(newEvent)
    }

    func applyLayout() {
        newHabit.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-38)
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        newEvent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(newHabit.snp.bottom).offset(16)
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
