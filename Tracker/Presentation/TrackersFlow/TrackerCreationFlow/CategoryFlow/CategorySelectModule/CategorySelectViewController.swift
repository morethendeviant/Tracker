//
//  CategorySelectViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import UIKit

protocol CategorySelectCoordinatorProtocol: AnyObject {
    var onHeadForCategoryCreation: (() -> Void)? { get set }
    var onFinish: ((String?) -> Void)? { get set }
    var headForError: ((String) -> Void)? { get set }
    
    func setNewCategory(_: String)
}

protocol TrackerCategoryDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersCategoryStoreUpdate)
}

final class CategorySelectViewController: BaseViewController {
    var onHeadForCategoryCreation: (() -> Void)?
    var onFinish: ((String?) -> Void)?
    var headForError: ((String) -> Void)?
    
    private var dataProvider: TrackerCategoriesDataProviderProtocol?
    private var selectedCategory: String?
    
    private lazy var categoriesTableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = true
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
        hideKeyboardWhenTappedAround()
    }
    
    init(pageTitle: String, selectedCategory: String?) {
        self.selectedCategory = selectedCategory
        super.init(pageTitle: pageTitle)
        
        self.dataProvider = {
            do {
                try dataProvider = TrackerCategoriesDataProvider(delegate: self, errorHandlerDelegate: self)
                return dataProvider
            } catch {
                handleError(message: "Данные недоступны")
                return nil
            }
        }()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategorySelectViewController: CategorySelectCoordinatorProtocol {
    func setNewCategory(_ category: String) {
        dataProvider?.addCategory(category)
    }
}

// MARK: - @objs

@objc private extension CategorySelectViewController {
    func addButtonTapped() {
        onHeadForCategoryCreation?()
    }
}

// MARK: - Private Methods

private extension CategorySelectViewController {
    func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        cell.backgroundColor = .ypBackground
        
        if let selectedCategory,
           let text = cell.textLabel?.text,
           selectedCategory == text {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .none
    }
}

// MARK: - Table View Delegate

extension CategorySelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoriesTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selectedCategory = categoriesTableView.cellForRow(at: indexPath)?.textLabel?.text
        onFinish?(selectedCategory)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        categoriesTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

// MARK: - Table View Data Source

extension CategorySelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataProvider?.numberOfItemsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.contentView.addInteraction(UIContextMenuInteraction(delegate: self))
        cell.textLabel?.text = dataProvider?.categoryName(at: indexPath)
        configureCell(cell, for: indexPath)
        return cell
    }
}

extension CategorySelectViewController: TrackerCategoryDataProviderDelegate {
    func didUpdate(_ update: TrackersCategoryStoreUpdate) {
        categoriesTableView.performBatchUpdates {
            if let insertedIndexPath = update.insertedIndex {
                categoriesTableView.insertRows(at: [insertedIndexPath], with: .fade)
            }
            
            if let deletedIndexPath = update.deletedIndex {
                categoriesTableView.deleteRows(at: [deletedIndexPath], with: .fade)
            }
            
            if let updatedIndexPath = update.updatedIndex {
                categoriesTableView.reloadRows(at: [updatedIndexPath], with: .fade)
            }
        }
        categoriesTableView.snp.updateConstraints { make in
            make.height.equalTo(categoriesTableView.numberOfRows(inSection: 0) * 75 - 1)
        }
        view.layoutIfNeeded()
    }
}

// MARK: - Menu Interaction Delegate

extension CategorySelectViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let location = interaction.view?.convert(location, to: categoriesTableView),
              let indexPath = categoriesTableView.indexPathForRow(at: location)
        else {
            return UIContextMenuConfiguration()
        }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                // TODO: - Implement edit ability
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
                self?.dataProvider?.deleteCategory(at: indexPath)
            }
            
            return UIMenu(children: [edit, delete])
        }
        
        return configuration
    }
}

// MARK: - Subviews configure + layout

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
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(categoriesTableView.numberOfRows(inSection: 0) * 75 - 1)
        }
        
        addButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
}

extension CategorySelectViewController: ErrorHandlerDelegate {
    func handleError(message: String) {
        headForError?(message)
    }
}
