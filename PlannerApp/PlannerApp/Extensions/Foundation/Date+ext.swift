//
//  Date+ext.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 6.08.23.
//

import Foundation

extension Date {
    
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let selfDate = calendar.dateComponents([.year, .month, .day], from: self)
        let compareDate = calendar.dateComponents([.year, .month, .day], from: otherDate)
        return selfDate == compareDate
    }
    
    func toString(_ formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }
}
