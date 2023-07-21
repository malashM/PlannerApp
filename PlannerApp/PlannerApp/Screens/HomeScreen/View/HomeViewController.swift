//
//  ViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import UIKit

final class HomeViewController: BaseViewController<HomeViewModel, HomeCoordinator> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
}


//MARK: Configure
private extension HomeViewController {
    func configureUI() {
        title = Constants.HomeScreen.title
    }
}

