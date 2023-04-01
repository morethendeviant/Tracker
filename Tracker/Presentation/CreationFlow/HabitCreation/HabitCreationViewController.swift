//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.03.2023.
//

import UIKit

final class HabitCreationViewController: BaseViewController, UITextFieldDelegate {

    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors = Array(1...18).map { UIColor(named: "ypSelection\($0)") }
    
    private var emojiSelectedItem: Int?
    private var colorSelectedItem: Int?
    private var selectedItem: IndexPath?
    
    private lazy var mainScrollView: UIScrollView = {
        let scroll = UIScrollView()
        
        return scroll
    }()
    
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
    
    private lazy var parametersTableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorColor = .ypGray
        return table
    }()
    
    private lazy var parametersCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collection.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)

        collection.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)
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
    
    private lazy var cancelButton = BaseButton(style: .cancel, text: "Отменить")
    private lazy var createButton = BaseButton(style: .disabled, text: "Создать")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader: id = CollectionHeaderView.identifier
        default: id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? CollectionHeaderView else { return UICollectionReusableView()}
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
                                                         height: 50),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .required)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
    }
}

extension HabitCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return emojis.count
        case 1: return colors.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0: if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell {
            cell.emoji = emojis[indexPath.item]
            return cell
        }
        case 1: if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell {
            cell.color = colors[indexPath.item]
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

extension HabitCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    
}

extension HabitCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = .ypBackground
        cell.layer.cornerRadius = 16
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.textLabel?.text = "Категория"
        case 1:
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.textLabel?.text = "Расписание"
        default: break
        }

        return cell
    }
    
    
}




//MARK: - Subviews configure + layout
private extension HabitCreationViewController {
    func addSubviews() {
        content.addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(trackerTitleTextField)
        mainStackView.setCustomSpacing(24, after: trackerTitleTextField)
        
        mainStackView.addArrangedSubview(parametersTableView)
        mainStackView.setCustomSpacing(32, after: parametersTableView)
        
        mainStackView.addArrangedSubview(parametersCollectionView)
        //mainStackView.setCustomSpacing(47, after: parametersCollectionView)
        
        mainStackView.addArrangedSubview(buttonsStack)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
    }
    
    func configure() {
        parametersTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: parametersTableView.frame.size.width, height: 1))
    }
    
    func applyLayout() {
        mainScrollView.snp.makeConstraints { make in
            make.top.equalTo(content)
            make.leading.equalTo(content).offset(16)
            make.trailing.equalTo(content).offset(-16)
            make.bottom.equalTo(content)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(mainScrollView.contentLayoutGuide)
            make.width.equalTo(mainScrollView.frameLayoutGuide)
        }
        
        trackerTitleTextField.snp.makeConstraints { make in
            make.height.equalTo(75)
        }
        
        parametersTableView.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        
        parametersCollectionView.snp.makeConstraints { make in
            make.height.equalTo(550)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        
    }
}
