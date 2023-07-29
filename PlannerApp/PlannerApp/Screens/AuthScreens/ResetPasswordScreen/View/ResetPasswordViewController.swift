//
//  ResetPasswordViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import RxSwift
import RxCocoa

final class ResetPasswordViewController: BaseViewController<ResetPasswordViewModel, ResetPasswordCoordinator> {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var resetPasswordButton: UIButton!
    
    private typealias Titles = Constants.Alert.Titles
    private typealias Messages = Constants.Alert.Messages
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        bindUserInteractions()
    }
    
}


//MARK: Conigure
private extension ResetPasswordViewController {
    func configureUI() {
        title = Constants.ResetPasswordScreen.title
        emailTextField.placeholder = Constants.LoginScreen.emailPlaceholder
        resetPasswordButton.setTitle(Constants.ButtonTitles.resetPassword, for: .normal)
    }
    
    func validAndresetPassword() {
        if viewModel.isValidEmail(emailTextField.text) {
            resetPassword()
        } else {
            emailTextField.becomeFirstResponder()
            showInfoAlert(title: Titles.errorResetPassword, message: Messages.invalidEmail)
        }
    }
    
    func resetPassword() {
        viewModel.resetPassword()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                switch result {
                case .success(_):
                    self?.showInfoAlert(title: Titles.success, message: Messages.successResetPassword) {
                        let model = self?.viewModel.generateModel()
                        self?.coordinator.backToLoginScreen(with: model)
                    }
                case .failure(let error):
                    self?.showInfoAlert(title: Titles.errorResetPassword, message: error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
}


//MARK: Binding
private extension ResetPasswordViewController {
    func bindViewModel() {
        viewModel.bindInputs(email: emailTextField.rx.text.orEmpty, using: disposeBag)
        
        viewModel.isLoading
            .drive(with: self) { sself, isLoading in
                sself.blockUI(isLoading)
            }
            .disposed(by: disposeBag)
        
        viewModel.allowResetPassword
            .drive(resetPasswordButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
    }
    
    func bindUserInteractions() {
        resetPasswordButton
            .rx
            .bindAction(using: disposeBag) { [weak self] in
                self?.resetPassword()
            }
        
        emailTextField
            .rx
            .bindAction(using: disposeBag) { [weak self] in
                self?.validAndresetPassword()
            }
    }
}
