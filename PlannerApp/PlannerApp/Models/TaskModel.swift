//
//  TaskModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 3.08.23.
//

import Foundation

struct TaskModel: Model {
    
    let objectId: String
    let title: String
    let description: String?
    let priority: TaskProirity
    let reminderDate: Date
    let status: TaskStatus
    
    private enum CodingKeys: CodingKey {
        case objectId
        case title
        case description
        case priority
        case reminderDate
        case status
    }
    
    init(objectId: String, title: String, description: String?, priority: TaskProirity, reminderDate: Date, status: TaskStatus) {
        self.objectId = objectId
        self.title = title
        self.description = description
        self.priority = priority
        self.reminderDate = reminderDate
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.objectId = try container.decode(String.self, forKey: .objectId)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.priority = try container.decode(TaskProirity.self, forKey: .priority)
        self.reminderDate = try container.decode(Date.self, forKey: .reminderDate)
        self.status = try container.decode(TaskStatus.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.objectId, forKey: .objectId)
        try container.encode(self.title, forKey: .title)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.reminderDate, forKey: .reminderDate)
        try container.encode(self.status, forKey: .status)
    }
}

enum TaskStatus: String, Codable {
    case toDo
    case done
}

enum TaskProirity: String, Codable {
    case low
    case medium
    case high
}
