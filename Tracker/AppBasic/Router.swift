//
//  Router.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

import UIKit

protocol Routable {
    func setRootViewController(viewController: Presentable)
    
    func present(_ module: Presentable?)
    func present(_ module: Presentable?, dismissCompletion: (() -> Void)?)
    func present(_ module: Presentable?, animated: Bool)
    func present(_ module: Presentable?, presentationStyle: UIModalPresentationStyle)
    func present(_ module: Presentable?, animated: Bool, presentationStyle: UIModalPresentationStyle, dismissCompletion: (() -> Void)?)
    func dismissModule(_ module: Presentable?)
    func dismissModule(_ module: Presentable?, completion: (() -> Void)?)
    func dismissModule(_ module: Presentable?, animated: Bool, completion: (() -> Void)?)
    
    func addToTabBar(_ module: Presentable?)
}

final class Router: NSObject {
    weak var delegate: RouterDelegate?
    private var completions: [UIViewController : (() -> Void)?]
    private var presentingViewController: Presentable?
    
    init(routerDelegate: RouterDelegate) {
        self.delegate = routerDelegate
        self.completions = [:]
    }
}

extension Router: Routable {
    func setRootViewController(viewController: Presentable) {
        presentingViewController = viewController
        delegate?.setRootViewController(presentingViewController)
    }
    
    func present(_ module: Presentable?, dismissCompletion: (() -> Void)? = nil) {
        present(module, animated: true, presentationStyle: .automatic, dismissCompletion: dismissCompletion)
    }
    
    func present(_ module: Presentable?) {
        present(module, animated: true, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable?, animated: Bool) {
        present(module, animated: animated, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable?, presentationStyle: UIModalPresentationStyle) {
        present(module, animated: true, presentationStyle: presentationStyle)
    }
    
    func present(_ module: Presentable?, animated: Bool, presentationStyle: UIModalPresentationStyle, dismissCompletion: (() -> Void)? = nil) {
        guard let controller = module?.toPresent() else { return }
        controller.modalPresentationStyle = presentationStyle
        controller.presentationController?.delegate = self
        presentingViewController?.toPresent()?.present(controller, animated: animated, completion: nil)
        presentingViewController = controller
        addCompletion(dismissCompletion, for: controller)
    }
    
    func dismissModule(_ module: Presentable?) {
        dismissModule(module, animated: true, completion: nil)
    }
    
    func dismissModule(_ module: Presentable?, completion: (() -> Void)?)  {
        dismissModule(module, animated: true, completion: completion)
    }
    
    func dismissModule(_ module: Presentable?, animated: Bool, completion: (() -> Void)?) {
        guard let controller = module?.toPresent() else { return }
        self.presentingViewController = module?.toPresent()?.presentingViewController
        controller.dismiss(animated: animated, completion: completion)
    }
    
    func addToTabBar(_ module: Presentable?) {
        guard let controller = module?.toPresent() else { return }
        guard let rootViewController = presentingViewController as? UITabBarController else { return }
        rootViewController.viewControllers?.forEach { tabBarController in
            if tabBarController !== controller { return }
        }
        var viewControllers = rootViewController.viewControllers ?? []
        viewControllers.append(controller)
        rootViewController.setViewControllers(viewControllers, animated: false)
    }
}


extension Router: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentingViewController = presentationController.presentingViewController
        runCompletion(for: presentationController.presentedViewController)
    }
}

private extension Router {
    func addCompletion(_ completion: (() -> Void)?, for controller: UIViewController?) {
        if let completion, let controller {
            completions[controller] = completion
        }
    }
    
    func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion?()
        completions.removeValue(forKey: controller)
    }
}
