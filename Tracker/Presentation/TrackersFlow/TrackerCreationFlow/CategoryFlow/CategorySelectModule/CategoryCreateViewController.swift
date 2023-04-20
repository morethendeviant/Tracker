//
//  CategoryCreateViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 18.04.2023.
//

import UIKit

protocol CategoryCreateCoordinatorProtocol: AnyObject {
    var onReturnWithDone: ((String) -> Void)? { get set }
}

final class CategoryCreateViewController: BaseViewController, CategoryCreateCoordinatorProtocol {
    var onReturnWithDone: ((String) -> Void)?
    
    private var categoryName: String = "" {
        didSet {
            if categoryName.isEmpty {
                doneButton.setUpAppearance(for: .disabled)
            } else {
                doneButton.setUpAppearance(for: .confirm)
            }
        }
    }
    
    private lazy var maxCharactersLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        return label
    }()

    private lazy var categoryNameTextField: UITextField = {
        let text = BaseTextField()
        text.placeholder = "Введите название категории"
        text.backgroundColor = .ypBackground
        text.layer.cornerRadius = 16
        text.delegate = self
        return text
    }()
    
    private lazy var doneButton: BaseButton = {
        let button = BaseButton(style: .confirm, text: "Готово")
        button.setUpAppearance(for: .disabled)
        button.addTarget(nil, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configure()
        applyLayout()
    }
    
    init(pageTitle: String) {
        super.init(pageTitle: pageTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CategoryCreateViewController {
    @objc func doneButtonTapped() {
        onReturnWithDone?(categoryName)
    }
}

// MARK: - Text Field Delegate

extension CategoryCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            categoryName = text
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.textLimit(existingText: textField.text, newText: string, limit: 10)
    }
    
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        
        let isAtLimit = (existingText ?? "").count + newText.count <= limit
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.maxCharactersLabel.snp.updateConstraints { make in
                make.height.equalTo(isAtLimit ? 0: 22)
            }
            
            self?.view.layoutIfNeeded()
        }
        
        if newText.isEmpty {
            categoryName.removeLast()
        } else {
            categoryName.append(newText)
        }
        
        return isAtLimit
    }
}

// MARK: - Subviews configure + layout

private extension CategoryCreateViewController {
    func addSubviews() {
        content.addSubview(categoryNameTextField)
        content.addSubview(maxCharactersLabel)
        content.addSubview(doneButton)
    }
    
    func configure() {
        view.backgroundColor = .ypWhite
    }
    
    func applyLayout() {
        categoryNameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
        }
        
        maxCharactersLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryNameTextField.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(0)
        }
        
        doneButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
}
