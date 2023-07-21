//
//  LoginCoordinator.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import UIKit

final class LoginCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(_ initialData: Model?) {
        let authManager = AuthManager()
        let viewModel = LoginViewModel(authManager: authManager, model: initialData as? LoginModel)
        let vc = LoginViewController(coordinator: self, viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToHomeScreen() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        goNext(homeCoordinator)
    }
    
    func goToResetPasswordScreen() {
        let resetPasswordCoordinator = ResetPasswordCoordinator(navigationController: navigationController)
        goNext(resetPasswordCoordinator)
    }
    
    func handleDataToBack(_ data: Model?) {
        guard let data = data as? LoginModel,
              let viewController = navigationController.visibleViewController as? LoginViewController else { return }
        viewController.viewModel.updateModel(data)
    }
    
    
}
