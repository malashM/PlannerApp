//
//  BasicViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import RxSwift
import RxCocoa

class BaseViewController<ViewModelType: ViewModel, CoordinatorType: Coordinator>: UIViewController, ConfigurableViewController {
    
    let viewModel: ViewModelType
    let coordinator: CoordinatorType
    let disposeBag = DisposeBag()
    
    private let tapGesture = UITapGestureRecognizer()
    private let activityIndicator = UIActivityIndicatorView()
    
    required init(coordinator: CoordinatorType, viewModel: ViewModelType) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: Self.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    deinit {
        coordinator.parentCoordinator?.finish(coordinator)
    }
    
}


//MARK: Configure
private extension BaseViewController {
    func configureUI() {
        activityIndicator.center = view.center
        
        view.addGestureRecognizer(tapGesture)
        view.addSubview(activityIndicator)
    }
}


//MARK: Binding
private extension BaseViewController {
    func bind() {
        tapGesture
            .rx
            .bindAction(using: disposeBag) { [weak self] in
            self?.view.endEditing(true)
        }
    }
}


//MARK: Shared methods
extension BaseViewController {
    
    func blockUI(_ block: Bool) {
        showOrHideSpinner(block)
        view.subviews.forEach { ($0 as? UIControl)?.isEnabled = !block }
    }
    
    func showOrHideSpinner(_ show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
