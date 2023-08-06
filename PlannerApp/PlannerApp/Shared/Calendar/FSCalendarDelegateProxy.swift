//
//  FSCalendarDelegateProxy.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 6.08.23.
//

import FSCalendar
import RxSwift
import RxCocoa

class FSCalendarDelegateProxy: DelegateProxy<FSCalendar, FSCalendarDelegate>, DelegateProxyType, FSCalendarDelegate {
    
    public init(calendar: FSCalendar) {
        super.init(parentObject: calendar, delegateProxy: FSCalendarDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { FSCalendarDelegateProxy(calendar: $0) }
    }
    
    static func currentDelegate(for object: FSCalendar) -> FSCalendarDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: FSCalendarDelegate?, to object: FSCalendar) {
        object.delegate = delegate
    }
}

