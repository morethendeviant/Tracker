//
//  CategorySelectViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import UIKit

protocol CategorySelectCoordinatorProtocol {
    var onHeadForCategoryCreation: (() -> Void)? { get set }
    var onFinish: ((Int?) -> Void)? { get set }
}

final class CategorySelectViewController: BaseViewController, CategorySelectCoordinatorProtocol {
    var onHeadForCategoryCreation: (() -> Void)?
    var onFinish: ((Int?) -> Void)?
    
    private var categories = CategoryContainer.shared.items
    private var selectedCategory: Int?
    
    private lazy var categoriesTableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorColor = .ypGray
        table.layer.cornerRadius = 16
        return table
    }()
    
    private lazy var addButton: BaseButton = {
        let button = BaseButton(style: .confirm, text: "Добавить категорию")
        button.addTarget(nil, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
    }
    
    init(pageTitle: String, selectedCategory: Int?) {
        self.selectedCategory = selectedCategory
        super.init(pageTitle: pageTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - @objs

@objc private extension CategorySelectViewController {
    func addButtonTapped() {
        onHeadForCategoryCreation?()
    }
}

//MARK: - Private Methods

private extension CategorySelectViewController {
    func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        cell.backgroundColor = .ypBackground
        cell.accessoryType = selectedCategory == indexPath.row ? .checkmark : .none
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .none
    }
}

//MARK: - Table View Delegate

extension CategorySelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoriesTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selectedCategory = indexPath.row
        onFinish?(selectedCategory)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        categoriesTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

//MARK: - Table View Data Source

extension CategorySelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        configureCell(cell, for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
}

//MARK: - Subviews configure + layout
private extension CategorySelectViewController {
    func addSubviews() {
        content.addSubview(categoriesTableView)
        content.addSubview(addButton)
    }
    
    func configure() {
        view.backgroundColor = .ypWhite
    }
    
    func applyLayout() {
        categoriesTableView.snp.makeConstraints { make in
            make.top.equalTo(content)
            make.leading.equalTo(content).offset(16)
            make.trailing.equalTo(content).offset(-16)
            make.height.equalTo(categoriesTableView.numberOfRows(inSection: 0) * 75 - 1)
        }
        
        addButton.snp.makeConstraints { make in
            make.leading.equalTo(content).offset(20)
            make.trailing.equalTo(content).offset(-20)
            make.height.equalTo(60)
            make.bottom.equalTo(content).offset(-50)
        }
    }
}
