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
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    private let outputEmail = BehaviorRelay<String>(value: "")
    
    var isLoading: Driver<Bool> { authManager.isLoading }
    
    var allowResetPassword: Driver<Bool> { outputEmail.asDriver().map(isValidEmail) }
    
    func bindInputs(email: ControlProperty<String>, using bag: DisposeBag) {
        email.bind(to: outputEmail).disposed(by: bag)
    }
    
    func resetPassword() -> Single<Void> {
        return authManager.resetPassword(for: outputEmail.value)
    }
    
    func generateModel() -> LoginModel {
        return LoginModel(email: outputEmail.value)
    }
    
    func loadData() { }
    
}
