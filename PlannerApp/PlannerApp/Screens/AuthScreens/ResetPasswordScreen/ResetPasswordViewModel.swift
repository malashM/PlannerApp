//
//  ResetPasswordViewModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import FirebaseAuth
import RxSwift
import RxCocoa

final class ResetPasswordViewModel: AuthViewModelInterface {
    
    let authManager: AuthManager
    
    private let outputEmail = BehaviorRelay<String>(value: "")
    
    required init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    var allowResetPassword: Driver<Bool> { outputEmail.asDriver().map(isValidEmail) }
    
    func bindInputs(email: ControlProperty<String>, using bag: DisposeBag) {
        email.bind(to: outputEmail).disposed(by: bag)
    }
    
    func resetPassword() -> Single<AuthDataResult?> {
        return authManager.resetPassword(email: outputEmail.value)
    }
    
    func generateModel() -> LoginModel {
        return LoginModel(email: outputEmail.value)
    }
    
    func loadData() { }
    
}
