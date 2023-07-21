//
//  Coordinator.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    func start(_ initialData: Model?)
    func finish(_ child: Coordinator?)
    func goNext(_ child: Coordinator, with data: Model?)
    func goBack(with data: Model?)
    func handleDataToBack(_ data: Model?)
}


//MARK: Default Implementation
extension Coordinator {
    
    func finish(_ child: Coordinator?) {
        childCoordinators.removeAll { $0 === child }
    }
    
    func goNext(_ child: Coordinator, with data: Model? = nil) {
        childCoordinators.append(child)
        child.parentCoordinator = self
        child.start(data)
    }
    
    func goBack(with data: Model? = nil) {
        navigationController.popViewController(animated: true)
        parentCoordinator?.handleDataToBack(data)
        parentCoordinator?.finish(self)
    }
    
    func handleDataToBack(_ data: Model?) { }
}
