//
//  ConfigurableViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//


import UIKit

protocol ConfigurableViewController: UIViewController, XibLoadable {
    associatedtype ViewModelType: ViewModel
    associatedtype CoordinatorType: Coordinator

    var viewModel: ViewModelType { get }
    var coordinator: CoordinatorType { get }
}
