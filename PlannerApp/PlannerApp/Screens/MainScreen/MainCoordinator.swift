//
//  MainCoordinator.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import UIKit

final class MainCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator? = nil
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(_ initialData: Model? = nil) {
        let viewModel = MainViewModel()
        let vc = MainViewController(coordinator: self, viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func goToLoginScreen() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        goNext(loginCoordinator)
    }
    
    func goToCreateAccountScreen() {
        let createAccountCoordinator = CreateAccountCoordinator(navigationController: navigationController)
        goNext(createAccountCoordinator)
    }
    
    
}
