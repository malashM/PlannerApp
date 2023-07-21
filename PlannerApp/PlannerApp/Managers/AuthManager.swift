//
//  AuthManager.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 20.07.23.
//

import FirebaseAuth
import RxSwift
import RxCocoa

protocol AuthenticationReading {
    var isLoading: Driver<Bool> { get }
}

protocol AuthenticationWriting {
    associatedtype ResultType
    func resetPassword(email: String) -> Single<ResultType>
    func createUser(email: String, password: String) -> Single<ResultType>
    func login(email: String, password: String) -> Single<ResultType>
    func deleteUser() -> Single<ResultType>
}

final class AuthManager: AuthenticationReading, AuthenticationWriting {
    
    private let loadingProcess = PublishRelay<Bool>()
    
    var isLoading: Driver<Bool> { loadingProcess.asDriver(onErrorJustReturn: false) }
    
    func resetPassword(email: String) -> Single<AuthDataResult?> {
        return executeOperation{ completion in Auth.auth().sendPasswordReset(withEmail: email) { completion(nil, $0) } }
    }
    
    func createUser(email: String, password: String) -> Single<AuthDataResult?> {
        return executeOperation { completion in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error { completion(nil, error) }
                result?.user.sendEmailVerification { completion(result, $0) }
            }
        }
    }
    
    func login(email: String, password: String) -> Single<AuthDataResult?> {
        return executeOperation{ completion in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error { completion(nil, error) }
                result?.user.isEmailVerified == true
                ? completion(result, error)
                : completion(nil, CustomError(Constants.Alert.Messages.verifyEmail))
            }
        }
    }
    
    func deleteUser() -> Single<AuthDataResult?> {
        let user = Auth.auth().currentUser
        let error = CustomError(Constants.Alert.Messages.noUser)
        guard let user else { return Single.error(error) }
        return executeOperation { completion in user.delete { completion(nil, $0) } }
    }
}


//MARK: - Private Methods
private extension AuthManager {
    
    typealias Completion = (@escaping (AuthDataResult?, Error?) -> Void) -> Void
    
    private func executeOperation(_ operation: @escaping Completion) -> Single<AuthDataResult?> {
        return Single.deferred {
            return Single.create { [weak self] single in
                self?.loadingProcess.accept(true)
                operation { result, error in
                    defer { self?.loadingProcess.accept(false) }
                    if let error = error {
                        single(.failure(error))
                    } else {
                        single(.success(result))
                    }
                }
                return Disposables.create()
            }
        }
    }
}


