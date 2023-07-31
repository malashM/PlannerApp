//
//  LoginModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 20.07.23.
//

import Foundation

struct LoginModel: Model {
    var objectId: String = ""
    var email: String?
    var password: String?
    
    init(email: String?, password: String? = nil) {
        self.email = email
        self.password = password
    }
}
