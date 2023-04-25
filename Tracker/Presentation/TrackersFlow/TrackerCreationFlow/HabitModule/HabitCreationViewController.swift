//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit



final class HabitCreationViewController: BaseViewController {
    
    private var viewModel: HabitCreationViewModelProtocol
    private var selectedItem: IndexPath?

    private lazy var mainScrollView = UIScrollView()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var trackerTitleTextField: UITextField = {
        let text = BaseTextField()
        text.placeholder = "Ведите название трекера"
        text.backgroundColor = .ypBackground
        text.layer.cornerRadius = 16
        text.delegate = self
        return text
    }()
    
    private lazy var maxCharactersLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        return label
    }()
    
    private lazy var parametersTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .ypWhite
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorColor = .ypGray
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        return table
    }()
    
    private lazy var parametersCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collection.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        
        collection.register(HabitCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HabitCollectionHeaderView.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.allowsMultipleSelection = false
        
        return collection
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var cancelButton: BaseButton = {
        let button = BaseButton(style: .cancel, text: "Отменить")
        button.addTarget(nil, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: BaseButton = {
        let button = BaseButton(style: .disabled, text: "Создать")
        button.addTarget(nil, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: HabitCreationViewModelProtocol, pageTitle: String? = nil) {
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
        setUpBindings()
        hideKeyboardWhenTappedAround()
    }
}

// MARK: - @objc

@objc private extension HabitCreationViewController {
    func cancelButtonTapped() {
        viewModel.cancelButtonTapped()
    }
    
    func createButtonTapped() throws {
        viewModel.createButtonTapped()
    }
    
    func scheduleCallTapped() {
        viewModel.scheduleCallTapped()
        
    }
    
    func categoryCellTapped() {
        viewModel.categoryCellTapped()
    }
}

// MARK: - Private Methods

private extension HabitCreationViewController {
    func setUpBindings() {
        viewModel.confirmEnabledObserver.bind { [weak self] isEnabled in
            if isEnabled {
                self?.createButton.setUpAppearance(for: .confirm)
            } else {
                self?.createButton.setUpAppearance(for: .disabled)
            }
        }
        
        viewModel.selectedCategoryObserver.bind { [weak self] category in
            guard let self else { return }
            
            self.parametersTableView.reloadData()

        }
        
        viewModel.weekdaysObserver.bind { [weak self] weekDays in
            guard let self else { return }
            
            self.parametersTableView.reloadData()
        }
        
    }
    
    func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .ypGray
        cell.textLabel?.textColor = .ypBlack
    }
}

// MARK: - Text Field Delegate

extension HabitCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.setTitle(textField.text!) // TODO: Refac
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.textLimit(existingText: textField.text, newText: string, limit: 38)
    }
    
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.maxCharactersLabel.snp.updateConstraints { make in
                make.height.equalTo(isAtLimit ? 0: 22)
            }
            
            self?.view.layoutIfNeeded()
        }
        
        viewModel.setTitle(isAtLimit ? text + newText : text)
        return isAtLimit
    }
}

// MARK: - Collection Flow Layout Delegate

extension HabitCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell else { return }
            cell.cellIsSelected = true
            viewModel.setEmoji(indexPath.item)
            
        case 1: guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            cell.cellIsSelected = true
            viewModel.setColor(indexPath.item)
            
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectedItem = indexPath
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let section = selectedItem?.section else { return }
        
        switch section {
        case 0:
            guard let item = viewModel.emojiSelectedItem,
                  let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? EmojiCollectionViewCell
            else { return }
            
            cell.cellIsSelected = false
        case 1:
            guard let item = viewModel.colorSelectedItem,
                  let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? ColorCollectionViewCell
            else { return }
            
            cell.cellIsSelected = false
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader: id = HabitCollectionHeaderView.identifier
        default: id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? HabitCollectionHeaderView else { return UICollectionReusableView()}
        switch indexPath.section {
        case 0: view.titleLabel.text = "Emoji"
        case 1: view.titleLabel.text = "Цвет"
        default: break
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: 34),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .required)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
}

// MARK: - Collection View Data Source

extension HabitCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return Emojis.count
        case 1: return Colors.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell {
            cell.emoji = Emojis[indexPath.item]
            return cell
        }
            
        case 1: if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell {
            if let colorName = Colors[indexPath.item] {
                cell.color = UIColor(named: colorName)
            }
            
            return cell
        }
            
        default: break
        }
        
        fatalError("Cell not found")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
}

// MARK: - Table View Data Source
extension HabitCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        configureCell(cell, for: indexPath)
        cell.textLabel?.text = viewModel.tableContent[indexPath.row].text
        cell.detailTextLabel?.text = viewModel.tableContent[indexPath.row].detailText
        return cell
    }
}

// MARK: - Table View Delegate
extension HabitCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: categoryCellTapped()
        case 1: scheduleCallTapped()
        default: break
        }
    }
}

// MARK: - Subviews configure + layout
private extension HabitCreationViewController {
    func addSubviews() {
        content.addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(trackerTitleTextField)
        mainStackView.setCustomSpacing(8, after: trackerTitleTextField)
        
        mainStackView.addArrangedSubview(maxCharactersLabel)
        mainStackView.setCustomSpacing(16, after: maxCharactersLabel)
        
        mainStackView.addArrangedSubview(parametersTableView)
        mainStackView.setCustomSpacing(16, after: parametersTableView)
        
        mainStackView.addArrangedSubview(parametersCollectionView)
        mainStackView.setCustomSpacing(16, after: parametersCollectionView)
        
        mainStackView.addArrangedSubview(buttonsStack)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
    }
    
    func applyLayout() {
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(mainScrollView.contentLayoutGuide)
            make.width.equalTo(mainScrollView.frameLayoutGuide)
        }
        
        trackerTitleTextField.snp.makeConstraints { make in
            make.height.equalTo(75)
            make.width.equalToSuperview().inset(16)
        }
        
        maxCharactersLabel.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.width.equalToSuperview().inset(16)
        }
        
        parametersTableView.snp.makeConstraints { make in
            make.height.equalTo(parametersTableView.numberOfRows(inSection: 0) * 75)
            make.width.equalToSuperview().inset(-4)
        }
        
        parametersCollectionView.snp.makeConstraints { make in
            make.height.equalTo(480)
            make.width.equalToSuperview().inset(16)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalToSuperview().inset(16)
        }
    }
}
