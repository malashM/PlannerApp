//
//  ViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController<HomeViewModel, HomeCoordinator> {
    
    private typealias ButtonTitle = Constants.ButtonTitles
    private typealias AlertTitle = Constants.Alert.Titles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        fetchUser()
    }
    
}


//MARK: - Configure
private extension HomeViewController {
    func configureUI() {
        let image = UIImage(systemName: Constants.Images.System.burger)
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(tapRightBarButtonItem(_:)))
        navigationItem.rightBarButtonItem = item
    }
    
    func generateActions() -> [UIAlertAction] {
        return [
            UIAlertAction(title: ButtonTitle.logOut, style: .default) { [weak self ] _ in self?.logOut() },
            UIAlertAction(title: ButtonTitle.deleteAccount, style: .destructive) { [weak self ] _ in self?.deleteAccount() }
        ]
    }
    
    func fetchUser() {
        viewModel.fetchCurrentUser()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { sself, model in
                guard let model else { return }
                sself.title = model.name
            } onFailure: { sself, error in
                sself.showInfoAlert(title: AlertTitle.error, message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    func logOut() {
        viewModel.logOut()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onSuccess: { sself, _ in
                sself.coordinator.goToMainScreen()
            }, onFailure: { sself, error in
                sself.showInfoAlert(title: AlertTitle.error, message: error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func deleteAccount() {
        showDeleteAlert() { [weak self] in
            guard let self else { return }
            self.viewModel.deleteAccount()
                .observe(on: MainScheduler.instance)
                .subscribe(with: self, onSuccess: { sself, _ in
                    sself.coordinator.goToMainScreen()
                }, onFailure: { sself, error in
                    sself.showInfoAlert(title: AlertTitle.error, message: error.localizedDescription)
                }).disposed(by: disposeBag)
        }
    }
    
    func showDeleteAlert(completion: @escaping (() -> Void)) {
        let title = ButtonTitle.deleteAccount
        let message = Constants.Alert.Messages.deleteAcc
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: ButtonTitle.delete, style: .destructive, handler: { _ in completion() })
        let cancelAction = UIAlertAction(title: ButtonTitle.cancel, style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
}

//MARK: - Binding
private extension HomeViewController {
    func bindViewModel() {
        viewModel.isLoading
            .drive(with: self) { sself, isLoading in
                sself.blockUI(isLoading)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Actions
private extension HomeViewController {
    @objc func tapRightBarButtonItem(_ sender: UIBarButtonItem) {
        let actions = generateActions()
        showBottomSheet(actions: actions)
    }
}

