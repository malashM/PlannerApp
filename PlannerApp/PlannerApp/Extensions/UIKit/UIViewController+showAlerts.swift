//
//  UIViewController+showAlerts.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 19.07.23.
//

import UIKit

extension UIViewController {
    func showInfoAlert(title: String, message: String? = nil, completion: (() -> Void)? = nil) {
        let actionTitle = Constants.ButtonTitles.okTitle.uppercased()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in completion?() }))
        present(alert, animated: true)
    }
}
