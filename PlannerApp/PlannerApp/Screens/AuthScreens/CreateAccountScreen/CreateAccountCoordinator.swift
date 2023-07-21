//
//  CreateAccountCoordinator.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import UIKit

final class CreateAccountCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(_ initialData: Model?) {
        let authManager = AuthManager()
        let viewModel = CreateAccountViewModel(authManager: authManager)
        let vc = CreateAccountViewController(coordinator: self, viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToLoginScreen(with data: LoginModel?) {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        goNext(loginCoordinator, with: data)
    }
    
    
}
