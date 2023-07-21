//
//  RxSwift+bindActions.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    func bindAction(using bag: DisposeBag, action: @escaping () -> Void) {
        self.tap
            .asDriver()
            .drive(onNext: { _ in action() })
            .disposed(by: bag)
    }
}

extension Reactive where Base: UITextField {
    func bindAction(using bag: DisposeBag, action: @escaping () -> Void) {
        self.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(onNext: { _ in action() })
            .disposed(by: bag)
    }
}

extension Reactive where Base: UITapGestureRecognizer {
    func bindAction(using bag: DisposeBag, action: @escaping () -> Void) {
        self.event
            .asDriver()
            .drive(onNext: { _ in action() })
            .disposed(by: bag)
    }
}
