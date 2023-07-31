//
//  UserModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 30.07.23.
//

import Foundation

struct UserModel: Model {
    
    let objectId: String
    let name: String
    let email: String
    
    private enum CodingKeys: String, CodingKey {
        case objectId
        case name
        case email
    }
    
    init(objectId: String = "", name: String, email: String) {
        self.objectId = objectId
        self.name = name
        self.email = email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.objectId = try container.decode(String.self, forKey: .objectId)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.objectId, forKey: .objectId)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.email, forKey: .email)
    }
}

