//
//  MainViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import UIKit

final class MainViewController: BaseViewController<MainViewModel, MainCoordinator> {
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindUserInteractions()
    }
    
}


//MARK: Configure
private extension MainViewController {
    func configureUI() {
        title = Constants.MainScreen.title
        loginButton.setTitle(Constants.ButtonTitles.login, for: .normal)
        createAccountButton.setTitle(Constants.ButtonTitles.createAccount, for: .normal)
    }
    
}


//MARK: Binding
private extension MainViewController {
    func bindUserInteractions() {
        loginButton.rx.bindAction(using: disposeBag) { [weak self] in
            guard let self else { return }
            self.coordinator.goToLoginScreen()
        }
        
        createAccountButton.rx.bindAction(using: disposeBag) { [weak self] in
            guard let self else { return }
            self.coordinator.goToCreateAccountScreen()
        }
    }
    
}
