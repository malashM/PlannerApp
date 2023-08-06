//
//  ViewController.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import RxSwift
import RxCocoa
import RxDataSources

final class HomeViewController: BaseViewController<HomeViewModel, HomeCoordinator> {
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var calendar: CustomCalendar!
    
    private typealias ButtonTitle = Constants.ButtonTitles
    private typealias AlertTitle = Constants.Alert.Titles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        bindViewModel()
        bindUserInteractions()
        fetchUser()
    }
    
}


//MARK: - Configure
private extension HomeViewController {
    func configureUI() {
        let image = UIImage(systemName: Constants.Images.System.burger)
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = item
    }
    
    func configureTableView() {
        tableView.registerCell(TaskTableViewCell.self)
    }
    
    func makeDataSource() -> RxTableViewSectionedReloadDataSource<TaskSectionModel> {
        return RxTableViewSectionedReloadDataSource<TaskSectionModel>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueCell(TaskTableViewCell.self, for: indexPath)
                cell?.configure(with: item)
                return cell ?? UITableViewCell()
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource.sectionModels[sectionIndex].header
            })
    }
    
    func generateActions() -> [UIAlertAction] {
        return [
            UIAlertAction(title: ButtonTitle.logOut, style: .default) { [weak self ] _ in self?.logOut() },
            UIAlertAction(title: ButtonTitle.deleteAccount, style: .destructive) { [weak self ] _ in self?.deleteAccount() }
        ]
    }
    
    func fetchUser() {
        viewModel.fetchCurrentUser()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { sself, model in
                guard let model else { return }
                sself.title = model.name
            } onFailure: { sself, error in
                sself.showInfoAlert(title: AlertTitle.error, message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    func logOut() {
        viewModel.logOut()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onSuccess: { sself, _ in
                sself.coordinator.goToMainScreen()
            }, onFailure: { sself, error in
                sself.showInfoAlert(title: AlertTitle.error, message: error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func deleteAccount() {
        showDeleteAlert() { [weak self] in
            guard let self else { return }
            self.viewModel.deleteAccount()
                .observe(on: MainScheduler.instance)
                .subscribe(with: self, onSuccess: { sself, _ in
                    sself.coordinator.goToMainScreen()
                }, onFailure: { sself, error in
                    sself.showInfoAlert(title: AlertTitle.error, message: error.localizedDescription)
                }).disposed(by: disposeBag)
        }
    }
    
    func showDeleteAlert(completion: @escaping (() -> Void)) {
        let title = ButtonTitle.deleteAccount
        let message = Constants.Alert.Messages.deleteAcc
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: ButtonTitle.delete, style: .destructive, handler: { _ in completion() })
        let cancelAction = UIAlertAction(title: ButtonTitle.cancel, style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func updateActiveTab(_ index: Int) {
        print(index)
    }
    
}

//MARK: - Binding
private extension HomeViewController {
    func bindViewModel() {
        viewModel.isLoading
            .drive(with: self) { sself, isLoading in sself.blockUI(isLoading) }
            .disposed(by: disposeBag)
        
        viewModel.taskSections
            .drive(tableView.rx.items(dataSource: makeDataSource()))
            .disposed(by: disposeBag)
        
        viewModel.taskSections
            .map { $0.flatMap { $0.items }.map { $0.reminderDate } }
            .drive(with: self) { sself, dates in sself.calendar.setRemainderDates(dates) }
            .disposed(by: disposeBag)
        
        viewModel.scrolledDate
            .distinctUntilChanged()
            .drive(with: self) { sself, date in sself.calendar.select(date, scrollToDate: true) }
            .disposed(by: disposeBag)
        
        viewModel.scrolledIndexPath
            .drive(with: self) { sself, index in sself.tableView.scrollToRow(at: index, at: .top, animated: true) }
            .disposed(by: disposeBag)
    }
    
    func bindUserInteractions() {
        navigationItem.rightBarButtonItem?
            .rx
            .bindAction(using: disposeBag, action: { [weak self] in
                guard let self else { return }
                let actions = self.generateActions()
                self.showBottomSheet(actions: actions)
            })
        
        segmentControl
            .rx
            .bindAction(using: disposeBag) { [weak self] index in
                guard let self else { return }
                self.updateActiveTab(index)
            }
        
        tableView
            .rx
            .didScroll
            .asDriver()
            .drive(with: self) { sself, _ in
                guard let cell = sself.tableView.visibleCells.first as? TaskTableViewCell else { return }
                sself.viewModel.handleDateFromVissibleCell(cell.remainderDate)
            }
            .disposed(by: disposeBag)
        
        tableView
            .rx
            .modelSelected(TaskModel.self)
            .asDriver()
            .drive(with: self) { sself, task in }
            .disposed(by: disposeBag)
        
        calendar
            .rx
            .didSelectDate
            .asDriver()
            .distinctUntilChanged()
            .drive(with: self) { sself, date in sself.viewModel.handleSelectedDate(date) }
            .disposed(by: disposeBag)
    }
}

