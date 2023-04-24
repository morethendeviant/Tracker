//
//  CategorySelectViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 02.04.2023.
//

import UIKit

final class CategorySelectViewController: BaseViewController {
    
    private var viewModel: CategorySelectViewModelProtocol
    private var selectedCategory: String?
    
    private lazy var dataSource: CategoriesDiffableDataSource = {
        let dataSource = CategoriesDiffableDataSource(categoriesTableView,
                                                      interactionDelegate: self,
                                                      selectedCategory: selectedCategory)
        return dataSource
    }()
    
    private lazy var categoriesTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
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
 
    init(viewModel: CategorySelectViewModelProtocol, pageTitle: String, selectedCategory: String?) {
        self.viewModel = viewModel
        self.selectedCategory = selectedCategory
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
        setUpBindings()
        hideKeyboardWhenTappedAround()
        categoriesTableView.dataSource = dataSource
        viewModel.viewDidLoad()
    }
}

// MARK: - @objs

@objc private extension CategorySelectViewController {
    func addButtonTapped() {
        viewModel.addButtonTapped()
    }
    
    func setUpBindings() {
        viewModel.categoriesObserver.bind { [weak self] categories in
            self?.dataSource.reload(categories)
        }
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
