//
//  HomeViewModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import FirebaseAuth
import RxSwift
import RxCocoa

final class HomeViewModel: AuthViewModelInterface {
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    private let storeManager = FirestoreManager<UserModel>()
    private let loadingProcess = PublishRelay<Bool>()
    
    var isLoading: Driver<Bool> {
        let first = authManager.isLoading
        let second = loadingProcess.asDriver(onErrorJustReturn: false)
        return Driver.merge(first, second)
    }
    
    func logOut() -> Single<Void> {
        return authManager.logOut()
    }
    
    func deleteAccount() -> Single<Void> {
        guard let user = authManager.currentUser else { return .error(CustomError(Constants.Alert.Messages.noUser)) }
        return authManager.deleteUser(user)
    }
    
    func fetchCurrentUser() -> Single<UserModel?> {
        guard let id = authManager.currentUser?.uid else { return .never() }
        return Single.create { [weak self] single in
            self?.loadingProcess.accept(true)
            self?.storeManager.get(id: id) { result in
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
    
    func loadData() { }
}
