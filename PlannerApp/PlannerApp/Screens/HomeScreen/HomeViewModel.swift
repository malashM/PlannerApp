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
    
    var isLoading: Driver<Bool> { authManager.isLoading }
    
    var currentUser: User? { authManager.currentUser }
    
    func logOut() -> Single<Void> {
        return authManager.logOut()
    }
    
    func deleteAccount() -> Single<Void> {
        guard let user = authManager.currentUser else { return .error(CustomError(Constants.Alert.Messages.noUser)) }
        return authManager.deleteUser(user)
    }
    
    func loadData() { }
}
