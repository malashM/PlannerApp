//
//  AuthViewModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 20.07.23.
//

import RxCocoa

protocol AuthViewModelInterface: ViewModel, Validatable {
    
    associatedtype AuthManagerType: AuthenticationReading & AuthenticationWriting
    var authLoading: Driver<Bool> { get }
    var authManager: AuthManagerType { get }
}


//MARK: - Default Implementation
extension AuthViewModelInterface {
    var authLoading: Driver<Bool> { authManager.isLoading }
}
