//
//  CategorySelectViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import UIKit

protocol TrackerCategoryDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersCategoryStoreUpdate)
}

final class CategorySelectViewController: BaseViewController {

    private var viewModel: CategorySelectViewModelProtocol

    private var selectedCategory: String?
    
    private lazy var categoriesTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = true
        table.separatorColor = .ypGray
        table.backgroundColor = .ypWhite
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
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
        setUpBindings()
        hideKeyboardWhenTappedAround()
    }
    
    init(viewModel: CategorySelectViewModelProtocol, pageTitle: String, selectedCategory: String?) {
        self.viewModel = viewModel
        self.selectedCategory = selectedCategory
        super.init(pageTitle: pageTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - @objs

@objc private extension CategorySelectViewController {
    func addButtonTapped() {
        viewModel.addButtonTapped()
    }
    
    func setUpBindings() {
        viewModel.categoriesUpdateObserver.bind { [weak self] update in
            guard let self, let update else { return }
            self.categoriesTableView.performBatchUpdates {
                if let insertedIndexPath = update.insertedIndex {
                    self.categoriesTableView.insertRows(at: [insertedIndexPath], with: .fade)
                }
                
                if let deletedIndexPath = update.deletedIndex {
                    self.categoriesTableView.deleteRows(at: [deletedIndexPath], with: .fade)
                }
                
                if let updatedIndexPath = update.updatedIndex {
                    self.categoriesTableView.reloadRows(at: [updatedIndexPath], with: .fade)
                }
            }
        }
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
        guard let selectedCategory else { return }
        viewModel.selectCategory(selectedCategory)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        categoriesTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

// MARK: - Table View Data Source

extension CategorySelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoriesAmount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.contentView.addInteraction(UIContextMenuInteraction(delegate: self))
        cell.textLabel?.text = viewModel.categoryAt(index: indexPath.row)
        configureCell(cell, for: indexPath)
        return cell
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
                self?.viewModel.deleteCategoryAt(index: indexPath.row)
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
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top).offset(-50)
        }
        
        addButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(50)
        }
    }
}
