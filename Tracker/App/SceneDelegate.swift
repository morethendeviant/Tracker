//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 27.03.2023.
//

import UIKit

protocol RouterDelegate: AnyObject {
    func setRootViewController(_ viewController: Presentable?)
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private let coordinatorFactory: CoordinatorsFactoryProtocol = CoordinatorFactory()
    private lazy var router: Routable = Router(routerDelegate: self)
    private lazy var appCoordinator = coordinatorFactory.makeAppCoordinator(router: router)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        appCoordinator.startFlow()
    }
}

extension SceneDelegate: RouterDelegate {
    func setRootViewController(_ viewController: Presentable?) {
        window?.rootViewController = viewController?.toPresent()
    }
}


