//
//  CustomCalendar.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 6.08.23.
//

import FSCalendar
import RxSwift
import RxCocoa

class CustomCalendar: FSCalendar {
    private var remainderDates = [Date]()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setRemainderDates(_ dates: [Date]) {
        remainderDates = dates
        reloadData()
    }
}


//MARK: - Data source
extension CustomCalendar: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dates = remainderDates.filter { $0.isSameDay(as: date) }
        return dates.count
    }
    
}

//MARK: - Configure
private extension CustomCalendar {
    
    func setup() {
        dataSource = self
        
        firstWeekday = 2
        allowsSelection = true
        
        appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]
        appearance.titleDefaultColor = .label
        appearance.weekdayTextColor =  .systemBlue
        appearance.headerTitleColor = .systemBlue
        scope = .month
    }
}
