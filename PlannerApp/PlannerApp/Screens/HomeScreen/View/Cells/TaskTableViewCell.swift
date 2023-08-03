//
//  TaskTableViewCell.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 3.08.23.
//

import UIKit

final class TaskTableViewCell: UITableViewCell, XibLoadable {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    @IBOutlet private weak var reminderLabel: UILabel!
    
    func configure(with task: TaskModel) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        priorityLabel.text = task.priority.rawValue.capitalized
        reminderLabel.text = .generateReminderText(task.reminderDate)
    }
    
}

private extension String {
    
    static func generateReminderText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E\n dd.MM.yy\n HH:mm"
        formatter.locale = Locale.current
        let dateString = formatter.string(from: date)
        return dateString
    }
}

private extension TaskTableViewCell {
    
    func generateReminderText() {
        
    }
}
