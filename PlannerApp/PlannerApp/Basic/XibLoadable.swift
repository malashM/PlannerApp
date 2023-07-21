//
//  XibLoadable.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import UIKit

protocol XibLoadable {
    static var nibName: String { get }
}

extension XibLoadable {
    static var nibName: String {
        return String(describing: self)
    }
}

extension XibLoadable where Self: UIView {
    static func nib() -> UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}
