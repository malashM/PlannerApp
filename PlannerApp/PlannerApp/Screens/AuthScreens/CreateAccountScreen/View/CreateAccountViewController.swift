//
//  CreateAccountViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import RxSwift
import RxCocoa

final class CreateAccountViewController: BaseViewController<CreateAccountViewModel, CreateAccountCoordinator> {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var newPasswordTextField: UITextField!
    @IBOutlet private weak var createButton: UIButton!
    
    private typealias Titles = Constants.Alert.Titles
    private typealias Messages = Constants.Alert.Messages
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        bindUserInteractions()
        
    }
}


//MARK: Configure
private extension CreateAccountViewController {
    func configureUI() {
        title = Constants.CreateAccountScreen.title
        emailTextField.placeholder = Constants.LoginScreen.emailPlaceholder
        newPasswordTextField.placeholder = Constants.LoginScreen.passwordPlaceholder
        createButton.setTitle(Constants.ButtonTitles.createAccount, for: .normal)
    }
    
    func handlerCreateUser() {
        viewModel.createUser()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                switch result {
                case .success(_):
                    let title = Titles.successCreateUser
                    let message = Messages.successCreateUser
                    let model = self?.viewModel.generateModel()
                    self?.showInfoAlert(title: title, message: message) { self?.coordinator.goToLoginScreen(with: model) }
                case .failure(let error):
                    self?.showInfoAlert(title: Titles.errorCreateUser, message: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}


//MARK: Binding
private extension CreateAccountViewController {
    func bindViewModel() {
        viewModel.bindInputs(email: emailTextField.rx.text.orEmpty, password: newPasswordTextField.rx.text.orEmpty, using: disposeBag)
        
        viewModel.authLoading
            .drive(with: self) { sself, isLoading in sself.blockUI(isLoading) }
            .disposed(by: disposeBag)
        
        viewModel.allowCreateUser
            .drive(createButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
    }
    
    func bindUserInteractions() {
        createButton.rx.bindAction(using: disposeBag) { [weak self] in
            guard let self else { return }
            self.handlerCreateUser()
        }
        
        emailTextField.rx.bindAction(using: disposeBag) { [weak self] in
            guard let self else { return }
            self.newPasswordTextField.becomeFirstResponder()
        }
        
        newPasswordTextField.rx.bindAction(using: disposeBag) { [weak self] in
            guard let self else { return }
            if self.viewModel.isValidEmail(self.emailTextField.text) {
                self.handlerCreateUser()
            } else {
                self.emailTextField.becomeFirstResponder()
                self.showInfoAlert(title: Titles.errorLogin, message: Messages.invalidEmail)
            }
        }
    }
    
}
