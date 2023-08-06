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
    
    var remainderDate: Date? {
        return reminderLabel.text?.toDate(formatter)
    }
    
    func configure(with task: TaskModel) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        priorityLabel.text = task.priority.rawValue.capitalized
        reminderLabel.text = task.reminderDate.toString(formatter)
    }
    
}

private extension TaskTableViewCell {
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = .dateFormat
        return formatter
    }
}

private extension String {
    
    static let dateFormat = "E\n dd.MM.yy\n HH:mm"
}
