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
    
    private let loadingProcess = PublishRelay<Bool>()
    
    private let storeManager = FirestoreManager<UserModel>()
    
    var isLoading: Driver<Bool> { loadingProcess.asDriver(onErrorJustReturn: false) }
    
    var currentUser: User? { auth.currentUser }
    
    func createUser(email: String, password: String, name: String) -> Single<AuthDataResult> {
        return executeOperation { [weak self] completion in
            self?.auth.createUser(withEmail: email, password: password) { data, error in
                if let error {
                    completion(.failure(error))
                    Logger.log(.warning, message: error.localizedDescription)
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
                    Logger.log(.warning, message: error.localizedDescription)
                } else {
                    guard let result else {
                        Logger.log(.warning, message: Constants.Alert.Messages.noUser)
                        return completion(.failure(CustomError(Constants.Alert.Messages.noUser)))
                    }
                    let user = result.user
                    if user.isEmailVerified {
                        let model = UserModel(name: user.displayName ?? "", email: email)
                        self?.storeManager.add(id: user.uid, model) { error in
                            if let error {
                                completion(.failure(error))
                            } else {
                                completion(.success(result))
                                Logger.log(.info, message: "User: \(user) log in successfully")
                            }
                        }
                    } else {
                        completion(.failure(CustomError(Constants.Alert.Messages.verifyEmail)))
                        Logger.log(.warning, message: Constants.Alert.Messages.verifyEmail)
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
                    Logger.log(.warning, message: error.localizedDescription)
                } else {
                    completion(.success(()))
                    Logger.log(.info, message: "Reset password to email: \(email) sent successfully")
                }
            }
        }
    }
    
    func deleteUser(_ user: User) -> Single<Void> {
        return executeOperation { [weak self] completion in
            self?.storeManager.delete(id: user.uid) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    user.delete { error in
                        if let error {
                            completion(.failure(error))
                            Logger.log(.warning, message: error.localizedDescription)
                        } else {
                            completion(.success(()))
                            Logger.log(.info, message: "User: \(user) deleted successfully")
                        }
                    }
                }
            }
        }
    }
    
    func logOut() -> Single<Void> {
        return executeOperation { [weak self] completion in
            do {
                try self?.auth.signOut()
                completion(.success(()))
                Logger.log(.info, message: "Log out successfully")
            } catch {
                completion(.failure(error))
                Logger.log(.warning, message: error.localizedDescription)
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
                Logger.log(.warning, message: error.localizedDescription)
            } else {
                completion(.success(()))
                Logger.log(.info, message: "User name: \(name) set successfully")
            }
        }
    }
    
    func setUserNameAndSendVerification(
        _ data: AuthDataResult?,
        _ name: String,
        _ completion: @escaping Completion<AuthDataResult>
    ) {
        guard let data else {
            Logger.log(.warning, message: Constants.Alert.Messages.noUser)
            return completion(.failure(CustomError(Constants.Alert.Messages.noUser)))
        }
        setUserName(for: data.user, with: name) { result in
            switch result {
            case .success:
                data.user.sendEmailVerification() { error in
                    if let error = error {
                        completion(.failure(error))
                        Logger.log(.warning, message: error.localizedDescription)
                    } else {
                        completion(.success((data)))
                        Logger.log(.info, message: "User: \(data.user) create successfully")
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


