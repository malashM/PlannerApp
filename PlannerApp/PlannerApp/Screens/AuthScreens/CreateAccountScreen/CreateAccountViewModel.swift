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
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    private let outputName = BehaviorRelay<String>(value: "")
    private let outputEmail = BehaviorRelay<String>(value: "")
    private let outputPassword = BehaviorRelay<String>(value: "")
    
    var isLoading: Driver<Bool> { authManager.isLoading }
    
    var allowCreateUser: Driver<Bool> {
        let isValidName = outputName.asDriver().map(isValidUserName)
        let isValidEmail = outputEmail.asDriver().map(isValidEmail)
        let isValidPassword = outputPassword.asDriver().map(isValidPassword)
        return Driver.combineLatest(isValidName, isValidEmail, isValidPassword).map { $0 && $1 && $2 }
    }
    
    func bindInputs(
        name: ControlProperty<String>,
        email: ControlProperty<String>,
        password: ControlProperty<String>,
        using bag: DisposeBag
    ) {
        name.bind(to: outputName).disposed(by: bag)
        email.bind(to: outputEmail).disposed(by: bag)
        password.bind(to: outputPassword).disposed(by: bag)
    }
    
    func createUser() -> Single<AuthDataResult> {
        return authManager
            .createUser(email: outputEmail.value, password: outputPassword.value)
            .flatMap { [weak self] result in
                guard let self else { return .error(CustomError(Constants.Alert.Messages.unknowError)) }
                return self.authManager
                    .setUserName(for: result.user, with: self.outputName.value)
                    .flatMap { self.authManager.sendEmailVerification(for: result.user).map{ result } }
            }
    }
    
    func generateModel() -> LoginModel {
        return LoginModel(email: outputEmail.value, password: outputPassword.value)
    }
    
    func loadData() { }
}
