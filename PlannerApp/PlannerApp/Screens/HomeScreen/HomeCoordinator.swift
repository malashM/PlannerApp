//
//  MainCoordinator.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import UIKit

final class HomeCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(_ initialData: Model? = nil) {
        let authManager = AuthManager()
        let viewModel = HomeViewModel(authManager: authManager)
        let vc = HomeViewController(coordinator: self, viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func goToMainScreen() {
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        mainCoordinator.start()
        sceneDelegate?.coordinator = mainCoordinator
    }
    
}
