//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 04.06.2023.
//

import UIKit

final class FiltersViewController: BaseViewController {

    private let viewModel: FiltersViewModelProtocol

    private lazy var filtersTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorColor = Asset.ypGray.color
        table.backgroundColor = Asset.ypWhite.color
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        return table
    }()
    
    init(viewModel: FiltersViewModelProtocol, pageTitle: String) {
        self.viewModel = viewModel
        super.init(pageTitle: pageTitle)
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

// MARK: - TableView Data Source

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filtersAmount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.backgroundColor = Asset.ypBackground.color
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.text = viewModel.filterFor(index: indexPath.row)
        cell.accessoryType = viewModel.selectedFilterIndex == indexPath.row ? .checkmark : .none
        return cell
    }
}

// MARK: - TableView Delegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectFilter(indexPath.row)
    }
}

// MARK: - Subviews configure + layout

private extension FiltersViewController {
    func addSubviews() {
        content.addSubview(filtersTableView)
    }

    func applyLayout() {
        filtersTableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(content)
            make.height.equalTo(75 * viewModel.filtersAmount)
        }
    }
}
