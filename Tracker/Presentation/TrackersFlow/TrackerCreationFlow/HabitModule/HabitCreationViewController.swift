//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit

protocol HabitCreationCoordinatorProtocol: AnyObject {
    var onCancel: (() -> Void)? { get set }
    var onCreate: (() -> Void)? { get set }
    var onHeadForCategory: ((Int?) -> Void)? { get set }
    var onHeadForSchedule: (([DayOfWeek]) -> Void)? { get set }
    
    func selectCategory(_ category: Int?)
    func returnWithWeekdays(_ days: [DayOfWeek])
}

protocol EventCreationCoordinatorProtocol: AnyObject {
    var onCancel: (() -> Void)? { get set }
    var onCreate: (() -> Void)? { get set }
    var onHeadForCategory: ((Int?) -> Void)? { get set }
    
    func selectCategory(_ category: Int?)
}

final class HabitCreationViewController: BaseViewController, EventCreationCoordinatorProtocol {
    
    var onCancel: (() -> Void)?
    var onCreate: (() -> Void)?
    var onHeadForCategory: ((Int?) -> Void)?
    var onHeadForSchedule: (([DayOfWeek]) -> Void)?
    
    private var categories: CategoryContainer
    private var dataStore: TrackerDataStoreProtocol
    
    private var tableContent: [CellContent]
    
    private var trackerTitle: String? {
        didSet {
            checkForConfirm()
        }
    }
    private var emojiSelectedItem: Int? {
        didSet {
            checkForConfirm()
        }
    }
    
    private var colorSelectedItem: Int? {
        didSet {
            checkForConfirm()
        }
    }
    
    private var selectedItem: IndexPath?
    private var selectedCategory: Int? {
        didSet {
            checkForConfirm()
        }
    }
    
    private var weekdays: [DayOfWeek] = [] {
        didSet {
            checkForConfirm()
        }
    }
    
    private var tracker: Tracker?
    
    private lazy var mainScrollView = UIScrollView()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
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
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorColor = .ypGray
        table.layer.cornerRadius = 16
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
    
    init(pageTitle: String? = nil, tableDataModel: TrackerCreationTableModel, dataStore: TrackerDataStoreProtocol) {
        self.categories = CategoryContainer.shared
        self.tableContent = tableDataModel.defaultTableContent()
        self.dataStore = dataStore
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
        hideKeyboardWhenTappedAround()
    }
}

// MARK: - @objc

@objc private extension HabitCreationViewController {
    func cancelButtonTapped() {
        onCancel?()
    }
    
    func createButtonTapped() throws {
        guard let tracker, let selectedCategory else { return }
        
        try dataStore.add(tracker, for: categories.items[selectedCategory])
        onCreate?()
    }
    
    func scheduleCallTapped() {
        onHeadForSchedule?(weekdays)
    }
    
    func categoryCellTapped() {
        onHeadForCategory?(selectedCategory)
    }
}

// MARK: - Private Methods

private extension HabitCreationViewController {
    func checkForConfirm() {
        if let text = trackerTitle, !text.isEmpty, let colorSelectedItem, let emojiSelectedItem, selectedCategory != nil {
            if tableContent.count == 1 {
                let weekdays = DayOfWeek.allCases.map { $0 }
                tracker = Tracker(name: text, color: colorSelectedItem, emoji: emojiSelectedItem, schedule: weekdays)
            }
            if tableContent.count == 2, !weekdays.isEmpty {
                tracker = Tracker(name: text, color: colorSelectedItem, emoji: emojiSelectedItem, schedule: weekdays)
            }
            createButton.setUpAppearance(for: .confirm)
        } else {
            tracker = nil
            createButton.setUpAppearance(for: .disabled)
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

// MARK: - Habit Creation Coordinator

extension HabitCreationViewController: HabitCreationCoordinatorProtocol {
    func selectCategory(_ categoryIndex: Int?) {
        selectedCategory = categoryIndex
        
        if let categoryIndex {
            tableContent[0] = CellContent(text: tableContent[0].text, detailText: categories.items[categoryIndex])
            parametersTableView.reloadData()
        }
    }
    
    func returnWithWeekdays(_ days: [DayOfWeek]) {
        weekdays = days
        let weekdaysText = DayOfWeek.shortNamesFor(days)
        tableContent[1] = CellContent(text: tableContent[1].text, detailText: weekdaysText)
        parametersTableView.reloadData()
    }
}

// MARK: - Text Field Delegate

extension HabitCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerTitle = textField.text
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
        trackerTitle = isAtLimit ? text + newText : text
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
            emojiSelectedItem = indexPath.item
            
        case 1: guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            cell.cellIsSelected = true
            colorSelectedItem = indexPath.item
            
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
            guard let item = emojiSelectedItem,
                  let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? EmojiCollectionViewCell
            else { return }
            
            cell.cellIsSelected = false
        case 1:
            guard let item = colorSelectedItem,
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
        tableContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        configureCell(cell, for: indexPath)
        cell.textLabel?.text = tableContent[indexPath.row].text
        cell.detailTextLabel?.text = tableContent[indexPath.row].detailText
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
    
    func configure() {
        parametersTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: parametersTableView.frame.size.width, height: 1))
    }
    
    func applyLayout() {
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(mainScrollView.contentLayoutGuide).inset(16)
            make.width.equalTo(mainScrollView.frameLayoutGuide).inset(16)
        }
        
        trackerTitleTextField.snp.makeConstraints { make in
            make.height.equalTo(75)
        }
        
        maxCharactersLabel.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        parametersTableView.snp.makeConstraints { make in
            make.height.equalTo(parametersTableView.numberOfRows(inSection: 0) * 75 - 1)
        }
        
        parametersCollectionView.snp.makeConstraints { make in
            make.height.equalTo(480)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
}
