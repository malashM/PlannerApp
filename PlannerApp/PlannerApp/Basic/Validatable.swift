//
//  Validatable.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 19.07.23.
//

import Foundation

protocol Validatable {
    func isValidUserName(_ name: String?) -> Bool
    func isValidEmail(_ email: String?) -> Bool
    func isValidPassword(_ password: String?) -> Bool
}


//MARK: Default implementation
extension Validatable {
    func isValidEmail(_ email: String?) -> Bool {
        guard let email else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String?) -> Bool {
        return password?.isEmpty == false
    }
    
    func isValidUserName(_ name: String?) -> Bool {
        return name?.isEmpty == false
    }
}
