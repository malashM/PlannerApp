//
//  LoginViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController<LoginViewModel, LoginCoordinator> {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    
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
private extension LoginViewController {
    func configureUI() {
        title = Constants.LoginScreen.title
        emailTextField.placeholder = Constants.LoginScreen.emailPlaceholder
        passwordTextField.placeholder = Constants.LoginScreen.passwordPlaceholder
        logInButton.setTitle(Constants.ButtonTitles.login, for: .normal)
        forgotPasswordButton.setTitle(Constants.ButtonTitles.forgotPassword, for: .normal)
    }
    
    func validateAndLogin() {
        if viewModel.isValidEmail(emailTextField.text) {
            login()
        } else {
            emailTextField.becomeFirstResponder()
            showInfoAlert(title: Titles.errorLogin, message: Messages.invalidEmail)
        }
    }
    
    func login() {
        viewModel.login()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                switch result {
                case .success(_):
                    self?.coordinator.goToHomeScreen()
                case .failure(let error):
                    self?.showInfoAlert(title: Titles.errorLogin, message: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
    }
}


//MARK: Binding
private extension LoginViewController {
    func bindViewModel() {
        viewModel.bindModel
            .drive(with: self) { sself, model in
                sself.emailTextField.text = model?.email
                sself.passwordTextField.text = model?.password
            }
            .disposed(by: disposeBag)
        
        viewModel.bindInputs(
            email: emailTextField.rx.text.orEmpty,
            password: passwordTextField.rx.text.orEmpty,
            using: disposeBag
        )
        
        viewModel.isLoading
            .drive(with: self) { sself, isLoading in
                sself.blockUI(isLoading)
            }
            .disposed(by: disposeBag)
        
        viewModel.allowLogin
            .drive(logInButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindUserInteractions() {
        logInButton
            .rx
            .bindAction(using: disposeBag) { [weak self] in
            self?.login()
        }
        
        forgotPasswordButton
            .rx
            .bindAction(using: disposeBag) { [weak self] in
            self?.coordinator.goToResetPasswordScreen()
        }
        
        emailTextField
            .rx
            .bindAction(using: disposeBag) { [weak self] in
            self?.passwordTextField.becomeFirstResponder()
        }
        
        passwordTextField
            .rx
            .bindAction(using: disposeBag) { [weak self] in
            self?.validateAndLogin()
        }
    }
    
}
