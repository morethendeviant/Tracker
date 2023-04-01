//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit

final class TrackerCreationViewController: BaseViewController {

    private let newHabit = BaseButton(style: .default, text: "Привычка")
    private let newEvent = BaseButton(style: .disabled, text: "Нерегулярное событие")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
        // Do any additional setup after loading the view.
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
