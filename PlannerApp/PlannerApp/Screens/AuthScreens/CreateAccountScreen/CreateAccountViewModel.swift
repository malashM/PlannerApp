//
//  CreateAccountViewModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import FirebaseAuth
import RxSwift
import RxCocoa

final class CreateAccountViewModel: AuthViewModelInterface {
    
    let authManager: AuthManager
    
    private let outputEmail = BehaviorRelay<String>(value: "")
    private let outputPassword = BehaviorRelay<String>(value: "")
    
    required init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    var allowCreateUser: Driver<Bool> {
        let isValidEmail = outputEmail.asDriver().map(isValidEmail)
        let isValidPassword = outputPassword.asDriver().map(isValidPassword)
        return Driver.combineLatest(isValidEmail, isValidPassword).map { $0 && $1 }
    }
    
    func bindInputs(email: ControlProperty<String>, password: ControlProperty<String>, using bag: DisposeBag) {
        email.bind(to: outputEmail).disposed(by: bag)
        password.bind(to: outputPassword).disposed(by: bag)
    }
    
    func createUser() -> Single<AuthDataResult?> {
        return authManager.createUser(email: outputEmail.value, password: outputPassword.value)
    }
    
    func generateModel() -> LoginModel {
        return LoginModel(email: outputEmail.value, password: outputPassword.value)
    }
    
    func loadData() { }
}
