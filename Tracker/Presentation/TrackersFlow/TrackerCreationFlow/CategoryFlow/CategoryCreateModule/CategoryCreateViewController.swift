//
//  CategoryCreateViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 18.04.2023.
//

import UIKit

final class CategoryCreateViewController: BaseViewController {
   
    private let viewModel: CategoryCreateViewModelProtocol
    
    private lazy var maxCharactersLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение \(viewModel.textLimit) символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        return label
    }()

    private lazy var categoryNameTextField: UITextField = {
        let textField = BaseTextField()
        textField.placeholder = "Введите название категории"
        textField.text = viewModel.categoryName
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.delegate = self
        return textField
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
        setUpBindings()
        categoryNameTextField.becomeFirstResponder()
    }
    
    init(viewModel: CategoryCreateViewModelProtocol, pageTitle: String) {
        self.viewModel = viewModel
        super.init(pageTitle: pageTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension CategoryCreateViewController {
    @objc func doneButtonTapped() {
        viewModel.returnDidTapped()
    }
    
    func setUpBindings() {
        viewModel.categoryNameObserver.bind { [weak self] name in
            let appearance: BaseButton.Style = name.isEmpty ? .disabled : .confirm
            self?.doneButton.setUpAppearance(for: appearance)
        }
    }
    
    func showLimitMessage(_ state: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.maxCharactersLabel.snp.updateConstraints { make in
                make.height.equalTo(state ? 0: 22)
            }
            
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - Text Field Delegate

extension CategoryCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            viewModel.setName(text)
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isAtLimit = viewModel.isAtTextLimit(existingText: textField.text, newText: string)
        showLimitMessage(isAtLimit)
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
