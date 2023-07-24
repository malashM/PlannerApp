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
    
    let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func logOut() -> Single<AuthDataResult?> {
        return authManager.logOut()
    }
    
    func loadData() { }
}
