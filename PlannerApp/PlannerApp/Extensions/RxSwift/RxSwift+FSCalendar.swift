//
//  RxSwift+FSCalendar.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 6.08.23.
//

import FSCalendar
import RxSwift
import RxCocoa

extension Reactive where Base: FSCalendar {
    
    var didSelectDate: ControlEvent<Date> {
        let source = FSCalendarDelegateProxy.proxy(for: base)
            .methodInvoked(#selector(FSCalendarDelegate.calendar(_:didSelect:at:)))
            .map { $0[1] as! Date }
        
        return ControlEvent(events: source)
    }
}
