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
    var currentUser: User? { get }
}

protocol AuthenticationWriting {
    func createUser(email: String, password: String, name: String) -> Single<AuthDataResult>
    func login(email: String, password: String) -> Single<AuthDataResult>
    func setUserName(for user: User, with name: String) -> Single<Void>
    func resetPassword(for email: String) -> Single<Void>
    func deleteUser(_ user: User) -> Single<Void>
    func logOut() -> Single<Void>
}

final class AuthManager: AuthenticationReading, AuthenticationWriting {
    
    private let auth: Auth
    
    init(auth: Auth = .auth()) {
        self.auth = auth
    }
    
    private let loadingProcess = BehaviorRelay<Bool>(value: false)
    
    var isLoading: Driver<Bool> { loadingProcess.asDriver() }
    
    var currentUser: User? { auth.currentUser }
    
    func createUser(email: String, password: String, name: String) -> Single<AuthDataResult> {
        return executeOperation { [weak self] completion in
            self?.auth.createUser(withEmail: email, password: password) { data, error in
                if let error {
                    completion(.failure(error))
                } else {
                    self?.setUserNameAndSendVerification(data, name, completion)
                }
            }
        }
    }
    
    func login(email: String, password: String) -> Single<AuthDataResult> {
        return executeOperation{ [weak self] completion in
            self?.auth.signIn(withEmail: email, password: password) { result, error in
                if let error {
                    completion(.failure(error))
                } else {
                    guard let result else { return completion(.failure(CustomError(Constants.Alert.Messages.noUser))) }
                    let user = result.user
                    if user.isEmailVerified {
                        let store = FirestoreManager<UserModel>()
                        let model = UserModel(name: user.displayName ?? "", email: email)
                        store.add(id: user.uid, model) { error in
                            if let error {
                                completion(.failure(error))
                            } else {
                                completion(.success(result))
                            }
                        }
                    } else {
                        completion(.failure(CustomError(Constants.Alert.Messages.verifyEmail)))
                    }
                }
            }
        }
    }
    
    func setUserName(for user: User, with name: String) -> Single<Void> {
        return executeOperation { [weak self] result in
            self?.setUserName(for: user, with: name, result)
        }
    }
    
    func resetPassword(for email: String) -> Single<Void> {
        return executeOperation { [weak self] completion in
            self?.auth.sendPasswordReset(withEmail: email) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func deleteUser(_ user: User) -> Single<Void> {
        return executeOperation { completion in
            let store = FirestoreManager<UserModel>()
            store.delete(id: user.uid) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    user.delete { error in
                        if let error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    func logOut() -> Single<Void> {
        return executeOperation { [weak self] completion in
            do {
                guard let self else { throw CustomError("\(String(describing: self)) has been deallocated.") }
                try self.auth.signOut()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}


//MARK: - Private Methods
private extension AuthManager {
    
    typealias Completion<T> = (Result<T, Error>) -> Void
    
    func executeOperation<T>(_ operation: @escaping (@escaping Completion<T>) -> Void) -> Single<T> {
        return Single.deferred {
            return Single.create { [weak self] single in
                self?.loadingProcess.accept(true)
                operation { [weak self] result in
                    defer { self?.loadingProcess.accept(false) }
                    switch result {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
                return Disposables.create()
            }
        }
    }
    
    func setUserName(
        for user: User,
        with name: String,
        _ completion: @escaping Completion<Void>
    ) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges() { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func setUserNameAndSendVerification(
        _ data: AuthDataResult?,
        _ name: String,
        _ completion: @escaping Completion<AuthDataResult>
    ) {
        guard let data else { return completion(.failure(CustomError(Constants.Alert.Messages.noUser))) }
        setUserName(for: data.user, with: name) { result in
            switch result {
            case .success:
                data.user.sendEmailVerification() { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success((data)))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


