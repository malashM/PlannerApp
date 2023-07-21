//
//  CustomError.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 21.07.23.
//

import Foundation

class CustomError: NSError {
    init(_ message: String) {
        super.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
