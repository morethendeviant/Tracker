//
//  Router.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import UIKit

protocol Routable {
    func setRootViewController(viewController: Presentable)
    
    func present(_ module: Presentable)
    func present(_ module: Presentable, animated: Bool)
    func present(_ module: Presentable, presentationStyle: UIModalPresentationStyle)
    func present(_ module: Presentable, animated: Bool, presentationStyle: UIModalPresentationStyle)
   
    func dismissModule(_ module: Presentable)
    func dismissModule(_ module: Presentable, completion: (() -> Void)?)
    func dismissModule(_ module: Presentable, animated: Bool, completion: (() -> Void)?)
         
    func addToTabBar(_ module: Presentable)
    //func presentAlert(_ module: Presentable, alert: AlertModel)
}

final class Router: NSObject {
    weak var delegate: RouterDelegate?
    
    private var presentingViewController: Presentable?
    
    init(routerDelegate: RouterDelegate) {
        self.delegate = routerDelegate
    }
}

extension Router: Routable {
    
    func setRootViewController(viewController: Presentable) {
        presentingViewController = viewController
        delegate?.setRootViewController(presentingViewController)
    }
    
    func present(_ module: Presentable) {
        present(module, animated: true, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable, animated: Bool) {
        present(module, animated: animated, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable, presentationStyle: UIModalPresentationStyle) {
        present(module, animated: true, presentationStyle: presentationStyle)
    }
    
    func present(_ module: Presentable, animated: Bool, presentationStyle: UIModalPresentationStyle) {
        guard let controller = module.toPresent() else { return }
        controller.modalPresentationStyle = presentationStyle
        controller.presentationController?.delegate = self
        presentingViewController?.toPresent()?.present(controller, animated: animated, completion: nil)
        presentingViewController = controller
    }
    
    func dismissModule(_ module: Presentable) {
        dismissModule(module, animated: true, completion: nil)
    }
    
    func dismissModule(_ module: Presentable, completion: (() -> Void)?)  {
        dismissModule(module, animated: true, completion: completion)
    }
    
    func dismissModule(_ module: Presentable, animated: Bool, completion: (() -> Void)?) {
        self.presentingViewController = module.toPresent()?.presentingViewController
        module.toPresent()?.dismiss(animated: animated, completion: completion)
    }
    
    func addToTabBar(_ module: Presentable) {
        guard let controller = module.toPresent() else { return }
        guard let rootViewController = presentingViewController as? UITabBarController else { return }
        rootViewController.viewControllers?.forEach { tabBarController in
            if tabBarController !== controller { return }
        }
        var viewControllers = rootViewController.viewControllers ?? []
        viewControllers.append(controller)
        rootViewController.setViewControllers(viewControllers, animated: false)
    }
    
//    func presentAlert(_ module: Presentable, alert: AlertModel) {
//        let controller = module.toPresent() as? AlertPresentable
//        controller?.presentAlertWith(alert)
//    }
}


extension Router: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.presentingViewController = presentationController.presentingViewController
    }
}
