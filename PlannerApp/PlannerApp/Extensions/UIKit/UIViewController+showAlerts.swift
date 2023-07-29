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
        let action = UIAlertAction(title: actionTitle, style: .default, handler: { _ in completion?() })
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showBottomSheet(actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: Constants.ButtonTitles.cancel, style: .cancel)
        actions.forEach(alertController.addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
