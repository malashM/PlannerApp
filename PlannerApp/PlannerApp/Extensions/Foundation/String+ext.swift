//
//  String+ext.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 6.08.23.
//

import Foundation

extension String {
    
    func toDate(_ formatter: DateFormatter) -> Date? {
        return formatter.date(from: self)
    }
}
