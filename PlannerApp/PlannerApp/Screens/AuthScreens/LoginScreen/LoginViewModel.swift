//
//  LoginViewModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import FirebaseAuth
import RxSwift
import RxCocoa

final class LoginViewModel: AuthViewModelInterface {
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager, model: LoginModel?) {
        self.authManager = authManager
        updateModel(model)
    }
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    private let outputEmail = BehaviorRelay<String>(value: "")
    private let outputPassword = BehaviorRelay<String>(value: "")
    private let outputModel = BehaviorRelay<LoginModel?>(value: nil)
    
    var isLoading: Driver<Bool> { authManager.isLoading }
    
    var allowLogin: Driver<Bool> {
        let isValidEmail = outputEmail.asDriver().map(isValidEmail)
        let isValidPassword = outputPassword.asDriver().map(isValidPassword)
        return Driver.combineLatest(isValidEmail, isValidPassword).map { $0 && $1 }
    }
    
    var bindModel: Driver<LoginModel?> { outputModel.asDriver() }
    
    func bindInputs(email: ControlProperty<String>, password: ControlProperty<String>, using bag: DisposeBag) {
        email.bind(to: outputEmail).disposed(by: bag)
        password.bind(to: outputPassword).disposed(by: bag)
    }
    
    func login() -> Single<AuthDataResult> {
        return authManager.login(email: outputEmail.value, password: outputPassword.value)
    }
    
    func updateModel(_ data: LoginModel?) {
        guard let data else { return }
        outputModel.accept(data)
        outputEmail.accept(data.email ?? "")
        outputPassword.accept(data.email ?? "")
    }
    
    func loadData() { }
}



