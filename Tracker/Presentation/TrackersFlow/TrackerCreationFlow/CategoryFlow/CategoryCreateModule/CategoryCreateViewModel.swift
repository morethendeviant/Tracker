//
//  CategoryCreateViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 22.04.2023.
//

import UIKit

protocol CategoryCreateCoordination: AnyObject {
    var onReturnWithDone: ((String) -> Void)? { get set }
}

protocol CategoryCreateViewModelProtocol {
    var categoryName: String { get }
    var categoryNameObserver: Observable<String> { get }
    
    func returnDidTapped()
    func setName(_ name: String)
    func isAtTextLimit(existingText: String?, newText: String) -> Bool
}

final class CategoryCreateViewModel: CategoryCreateCoordination {
    var onReturnWithDone: ((String) -> Void)?
    
    @Observable private(set) var categoryName: String = ""
}

extension CategoryCreateViewModel: CategoryCreateViewModelProtocol {
    var categoryNameObserver: Observable<String> {
        $categoryName
    }
    
    func setName(_ name: String) {
        categoryName = name
    }
    
    func returnDidTapped() {
        onReturnWithDone?(categoryName)
    }
    
    func isAtTextLimit(existingText: String?, newText: String) -> Bool {
        let isAtLimit = (existingText ?? "").count + newText.count <= 38
        if newText.isEmpty {
            categoryName.removeLast()
        } else {
            categoryName.append(newText)
        }
        
        return isAtLimit
    }
}
