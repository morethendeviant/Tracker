//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import UIKit

final class ScheduleViewController: BaseViewController {
        
    private let viewModel: ScheduleViewModelProtocol
    
    private var mainScrollView = UIScrollView()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var daysOfWeekTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = true
        table.backgroundColor = .ypWhite
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.separatorColor = .ypGray
        return table
    }()
    
    private lazy var doneButton: BaseButton = {
        let button = BaseButton(style: .confirm, text: "Готово")
        button.addTarget(nil, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
     
    init(viewModel: ScheduleViewModelProtocol, pageTitle: String?) {
        self.viewModel = viewModel
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

// MARK: - @objs

@objc private extension ScheduleViewController {
    func doneButtonTapped() {
        viewModel.doneButtonTapped()
    }
    
    func toggleSwitch(sender: UISwitch) {
        viewModel.setDayAt(index: sender.tag, to: sender.isOn)
    }
}

// MARK: - Private Methods

private extension ScheduleViewController {
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        cell.backgroundColor = .ypBackground
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .none
    }
    
    func createDaySwitchFor(index: Int) -> UISwitch {
        let daySwitch = UISwitch()
        daySwitch.tag = index
        daySwitch.addTarget(nil, action: #selector(toggleSwitch), for: .valueChanged)
        daySwitch.onTintColor = .ypBlue
        daySwitch.isOn = viewModel.isDaySelectedAt(index: index)
        return daySwitch
    }
}

// MARK: - Table View Delegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - Table View Data Source

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.daysAmount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        configureCell(cell, indexPath: indexPath)
        cell.accessoryView = createDaySwitchFor(index: indexPath.row)
        cell.textLabel?.text = viewModel.dayNameAt(index: indexPath.row)
        return cell
    }
}

// MARK: - Subviews configure + layout

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
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(doneButton.snp.top).offset(-50)
        }
        
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(50)
        }
    }
}
