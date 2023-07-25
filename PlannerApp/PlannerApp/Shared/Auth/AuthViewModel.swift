//
//  AuthViewModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 20.07.23.
//

import RxCocoa

protocol AuthViewModelInterface: ViewModel, Validatable {
    
    associatedtype AuthManagerType: AuthenticationReading & AuthenticationWriting
    var isLoading: Driver<Bool> { get }
    init(authManager: AuthManagerType)
}
