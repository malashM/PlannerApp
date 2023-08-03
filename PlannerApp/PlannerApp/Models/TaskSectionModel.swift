//
//  TaskSectionModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 3.08.23.
//

import RxDataSources

struct TaskSectionModel {
    var header: String?
    var groupingStyle: GroupingStyle
    var items: [TaskModel]
}

extension TaskSectionModel: SectionModelType {
    
    init(original: TaskSectionModel, items: [TaskModel]) {
        self = original
        self.items = items
    }
}

enum GroupingStyle {
    case day
    case week
    case month
    case year
}
