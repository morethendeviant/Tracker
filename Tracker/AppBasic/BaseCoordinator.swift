//
//  BaseCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.04.2023.
//

protocol Coordinatable: AnyObject {
    func startFlow()
}

class BaseCoordinator {
    var childCoordinators: [Coordinatable] = []
  
    func addDependency(_ coordinator: Coordinatable) {
        childCoordinators.forEach { childCoordinator in
            if childCoordinator === coordinator { return }
        }
        childCoordinators.append(coordinator)
        print("test", childCoordinators)
    }
    
    func removeDependency(_ coordinator: Coordinatable?) {
        guard let coordinator = coordinator else { return }
        childCoordinators.removeAll { childCoordinator in
            childCoordinator === coordinator
        }
        print("test", childCoordinators)

    }
}
