//
//  ViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import RxSwift
import RxCocoa
import FirebaseAuth

final class HomeViewController: BaseViewController<HomeViewModel, HomeCoordinator> {
    
    private typealias Titles = Constants.Alert.Titles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        bindUserInteractions()
    }
    
}


//MARK: - Configure
private extension HomeViewController {
    func configureUI() {
        title = viewModel.currentUser?.displayName
        let item = UIBarButtonItem(title: Constants.ButtonTitles.logOut, style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = item
    }
    
}

//MARK: - Binding
private extension HomeViewController {
    func bindUserInteractions() {
        navigationItem.rightBarButtonItem?.rx.tap
            .flatMapLatest { [weak self] _ in self?.viewModel.logOut() ?? .just(()) }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { sself, _ in
                sself.coordinator.goToMainScreen()
            }, onError: { sself, error in
                sself.showInfoAlert(title: Titles.errorLogin, message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel.isLoading
            .drive(with: self) { sself, isLoading in sself.blockUI(isLoading) }
            .disposed(by: disposeBag)
    }
}

