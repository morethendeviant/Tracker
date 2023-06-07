//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit

final class HabitCreationViewController: BaseViewController {
    
    private var viewModel: HabitCreationViewModelProtocol
    private var emojiSelectedItem: Int?
    private var colorSelectedItem: Int?
    private var confirmButtonText: String
    
    private var categoryName: String?
    
    private lazy var mainScrollView = UIScrollView()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var daysEditStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        return stack
    }()
    
    private lazy var minusButton = PlusMinusButton(mode: .minus)
    private lazy var plusButton = PlusMinusButton(mode: .plus)
    
    private lazy var daysAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = Asset.ypBlack.color
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trackerTitleTextField: UITextField = {
        let text = BaseTextField()
        text.placeholder = NSLocalizedString("tracker.name", comment: "Tracker name text field placeholder")
        text.backgroundColor = Asset.ypBackground.color
        text.layer.cornerRadius = 16
        text.delegate = self
        return text
    }()
    
    private lazy var maxCharactersLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("stringLengthLimit", comment: "Limit on tracker name length")
        label.font = .systemFont(ofSize: 17)
        label.textColor = Asset.ypRed.color
        label.textAlignment = .center
        return label
    }()
    
    private lazy var parametersTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = Asset.ypWhite.color
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorColor = Asset.ypGray.color
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        return table
    }()
    
    private lazy var parametersCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collection.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collection.register(HabitCollectionHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: HabitCollectionHeaderView.identifier)
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
        let buttonText = NSLocalizedString("cancel", comment: "Cancel button title")
        let button = BaseButton(style: .cancel, text: buttonText)
        button.addTarget(nil, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: BaseButton = {let createText = NSLocalizedString("create", comment: "Create button title")
        let button = BaseButton(style: .disabled, text: confirmButtonText)
        button.addTarget(nil, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: HabitCreationViewModelProtocol, pageTitle: String? = nil, confirmButtonText: String) {
        self.viewModel = viewModel
        self.confirmButtonText = confirmButtonText
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
        viewModel.viewDidLoad()
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
        
        viewModel.selectedCategoryObserver.bind { [weak self] _ in
            guard let self else { return }
            self.parametersTableView.reloadData()
        }
        
        viewModel.weekdaysObserver.bind { [weak self] _ in
            guard let self else { return }
            self.parametersTableView.reloadData()
        }
        
        viewModel.trackerViewModelObserver.bind { [weak self] model in
            guard let model, let self else { return }
            self.trackerTitleTextField.text = model.name
            self.emojiSelectedItem = model.emoji
            self.colorSelectedItem = model.color
            
            daysAmountLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("numberOfDays", comment: "Number of checked days"),
                model.daysAmount
            )
            addDaysEditView()
        }
    }
    
    func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.backgroundColor = Asset.ypBackground.color
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = Asset.ypGray.color
        cell.textLabel?.textColor = Asset.ypBlack.color
    }
}

// MARK: - Text Field Delegate

extension HabitCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            viewModel.setTitle(text)
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.textLimit(existingText: textField.text, newText: string, limit: 38)
    }
    
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        var text = existingText ?? ""
        if newText.isEmpty, !text.isEmpty {
            text = String(text.dropLast(1))
        }
        
        let isAtLimit = text.count + newText.count <= limit
        if !isAtLimit {
            UIView.animate(withDuration: 0.2,
                           animations: { [weak self] in
                self?.maxCharactersLabel.snp.updateConstraints { make in
                    make.height.equalTo(22)
                }
                
                self?.view.layoutIfNeeded()
            },
                           completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 1) { [weak self] in
                    self?.maxCharactersLabel.snp.updateConstraints { make in
                        make.height.equalTo(0)
                    }
                    
                    self?.view.layoutIfNeeded()
                }
            })
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
        case 0:
            if let emojiSelectedItem,
               let cell = collectionView.cellForItem(at: IndexPath(row: emojiSelectedItem, section: 0)) as? EmojiCollectionViewCell {
                cell.cellIsSelected = false
            }
        case 1:
            if let colorSelectedItem,
               let cell = collectionView.cellForItem(at: IndexPath(row: colorSelectedItem, section: 1)) as? ColorCollectionViewCell {
                cell.cellIsSelected = false
                self.colorSelectedItem = indexPath.row
            }
        default: break
        }
        
        switch indexPath.section {
        case 0: guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell else { return }
            cell.cellIsSelected = true
            viewModel.setEmoji(indexPath.item)
            self.emojiSelectedItem = indexPath.row
        case 1: guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            cell.cellIsSelected = true
            viewModel.setColor(indexPath.item)
            self.colorSelectedItem = indexPath.row
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
        case 0: view.titleLabel.text = NSLocalizedString("emoji", comment: "Emoji section label text")
        case 1: view.titleLabel.text = NSLocalizedString("colors", comment: "Colors section label text")
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
            cell.cellIsSelected = indexPath.item == viewModel.screenContent.emoji
            return cell
        }
            
        case 1: if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell {
            if let colorName = Colors[indexPath.item] {
                cell.color = UIColor(named: colorName)
                cell.cellIsSelected = indexPath.item == viewModel.screenContent.color
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
        switch viewModel.tableDataModel {
        case .event: return 1
        case .habit: return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        configureCell(cell, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = viewModel.screenContent.categoryCellName
            cell.detailTextLabel?.text = viewModel.screenContent.categoryName
            return cell
        case 1:
            cell.textLabel?.text = viewModel.screenContent.scheduleCellName
            cell.detailTextLabel?.text = viewModel.screenContent.scheduleText
            return cell
        default:
            return UITableViewCell()
        }
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
        
        mainStackView.addArrangedSubview(daysEditStackView)
        
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
    
    func addDaysEditView() {
        mainStackView.setCustomSpacing(48, after: daysEditStackView)
        daysEditStackView.addArrangedSubview(minusButton)
        daysEditStackView.addArrangedSubview(daysAmountLabel)
        daysEditStackView.addArrangedSubview(plusButton)
        
        daysEditStackView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.width.equalToSuperview().inset(78)
        }
    }
}
