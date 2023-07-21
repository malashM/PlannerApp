//
//  ResetPasswordCoordinator.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import UIKit

final class ResetPasswordCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(_ initialData: Model?) {
        let authManager = AuthManager()
        let viewModel = ResetPasswordViewModel(authManager: authManager)
        let vc = ResetPasswordViewController(coordinator: self, viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func backToLoginScreen(with data: LoginModel?) {
        goBack(with: data)
    }
    
    
}
