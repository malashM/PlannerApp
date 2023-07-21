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
    
    func start(_ initialData: Model?) {
        let viewModel = HomeViewModel()
        let vc = HomeViewController(coordinator: self, viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}
