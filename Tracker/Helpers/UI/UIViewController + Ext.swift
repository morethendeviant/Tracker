//
//  UIViewController + Ext.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import UIKit

protocol Presentable {
    func toPresent() -> UIViewController?
}

//protocol UserDismissable: UIAdaptivePresentationControllerDelegate where Self: UIViewController {
//    func setUserDismissDelegate()
//}

extension UIViewController: Presentable {
    func toPresent() -> UIViewController? {
        return self
    }
}

//extension UIViewController: UserDismissable {
//    func setUserDismissDelegate() {
//        presentationController?.delegate = self
//    }
//}
