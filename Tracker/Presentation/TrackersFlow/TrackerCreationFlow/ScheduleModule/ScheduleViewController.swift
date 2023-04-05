//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import UIKit

protocol ScheduleViewCoordinatorProtocol {
    var onFinish: (([DayOfWeek]) -> Void)? { get set }
}

final class ScheduleViewController: BaseViewController, ScheduleViewCoordinatorProtocol {
    var onFinish: (([DayOfWeek]) -> Void)?
    
    private var selectedDays: [DayOfWeek] = []
    
    private lazy var daysOfWeekTableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorColor = .ypGray
        table.layer.cornerRadius = 16
        return table
    }()
    
    private lazy var doneButton: BaseButton = {
        let button = BaseButton(style: .confirm, text: "Готово")
        button.addTarget(nil, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
     
    init(pageTitle: String?, weekdays: [DayOfWeek]) {
        selectedDays = weekdays
        super.init(pageTitle: pageTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
    }
}

//MARK: - @objs

@objc private extension ScheduleViewController {
    func doneButtonTapped() {
        onFinish?(selectedDays)
    }
    
    func toggleSwitch(sender: UISwitch) {
        let day = DayOfWeek.dayFromNumber(sender.tag)
        if sender.isOn {
            selectedDays.append(day)
        } else {
            selectedDays.removeAll(where: { $0 == day })
        }
    }
}

//MARK: - Private Methods

private extension ScheduleViewController {
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        cell.backgroundColor = .ypBackground
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .none
    }
    
    func createDaySwitchFor(indexPath: IndexPath) -> UISwitch {
        let daySwitch = UISwitch()
        daySwitch.tag = indexPath.row
        daySwitch.addTarget(nil, action: #selector(toggleSwitch), for: .valueChanged)
        daySwitch.onTintColor = .ypBlue
        daySwitch.isOn = selectedDays.map { $0.rawValue }.contains(indexPath.row)
        return daySwitch
    }
}

//MARK: - Table View Delegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: - Table View Data Source

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DayOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        configureCell(cell, indexPath: indexPath)
        cell.accessoryView = createDaySwitchFor(indexPath: indexPath)
        cell.textLabel?.text = DayOfWeek.fullNameFor(indexPath.row)
        return cell
    }
}

//MARK: - Subviews configure + layout

private extension ScheduleViewController {
    func addSubviews() {
        content.addSubview(daysOfWeekTableView)
        content.addSubview(doneButton)
    }
    
    func configure() {
        view.backgroundColor = .ypWhite
    }
    
    func applyLayout() {
        daysOfWeekTableView.snp.makeConstraints { make in
            make.top.equalTo(content)
            make.leading.equalTo(content).offset(16)
            make.trailing.equalTo(content).offset(-16)
            make.height.equalTo(daysOfWeekTableView.numberOfRows(inSection: 0) * 75 - 1)
        }
        
        doneButton.snp.makeConstraints { make in
            make.leading.equalTo(content).offset(20)
            make.trailing.equalTo(content).offset(-20)
            make.height.equalTo(60)
            make.bottom.equalTo(content).offset(-50)
        }
    }
}
