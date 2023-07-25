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
    func createUser(email: String, password: String) -> Single<AuthDataResult>
    func login(email: String, password: String) -> Single<AuthDataResult>
    func sendEmailVerification(for user: User) -> Single<Void>
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
    
    func createUser(email: String, password: String) -> Single<AuthDataResult> {
        return executeOperation { [weak self] completion in
            self?.auth.createUser(withEmail: email, password: password) { result, error in
                if let error {
                    completion(.failure(error))
                } else {
                    guard let result else { return completion(.failure(CustomError(Constants.Alert.Messages.noUser))) }
                    result.user.
                    completion(.success(result))
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
                    
                    completion(.success(result))
                }
            }
        }
    }
    
    func sendEmailVerification(for user: User) -> Single<Void> {
        return executeOperation { completion in
            user.sendEmailVerification() { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func setUserName(for user: User, with name: String) -> Single<Void> {
        return executeOperation { [weak self] result in self?.setUserName(for: user, with: name, result) }
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
            user.delete { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            
        }
    }
    
    func logOut() -> Single<Void> {
        return executeOperation { [weak self] completion in
            guard let self else {
                return completion(.failure(CustomError("\(String(describing: self)) has been deallocated.")))
            }
            do {
                try self.auth.signOut()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    deinit {
        print("----->deinit: \(String(describing: self))")
    }
    
}


//MARK: - Private Methods
private extension AuthManager {
    
    typealias Completion<T> = (@escaping (Result<T, Error>) -> Void) -> Void
    
    func executeOperation<T>(_ operation: @escaping Completion<T>) -> Single<T> {
        return Single.deferred {
            return Single.create { [weak self] single in
                guard let self else {
                    single(.failure(CustomError("\(String(describing: self)) has been deallocated.")))
                    return Disposables.create()
                }
                self.loadingProcess.accept(true)
                print("----> loadingProcess.accept(true)")
                operation { [weak self] result in
                    defer { self?.loadingProcess.accept(false)
                        print("----> loadingProcess.accept(false)")
                    }
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
    
    func setUserName(for user: User, with name: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
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
}


