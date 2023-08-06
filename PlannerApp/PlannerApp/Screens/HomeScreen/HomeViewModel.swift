//
//  HomeViewModel.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 18.07.23.
//

import FirebaseAuth
import RxSwift
import RxCocoa

final class HomeViewModel: AuthViewModelInterface {
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    private let storeManager = FirestoreManager<UserModel>()
    private let loadingProcess = PublishRelay<Bool>()
    private let taskSectionsProcess = BehaviorRelay<[TaskSectionModel]>(value: [])
    private let scrolledDateProcess = PublishRelay<Date>()
    private let scrolledIndexPathProcess = PublishRelay<IndexPath>()
    
    var taskSections: Driver<[TaskSectionModel]> { taskSectionsProcess.asDriver() }
    var scrolledDate: Driver<Date> { scrolledDateProcess.asDriver(onErrorDriveWith: Driver.empty()) }
    var scrolledIndexPath: Driver<IndexPath> { scrolledIndexPathProcess.asDriver(onErrorDriveWith: Driver.empty()) }
    var isLoading: Driver<Bool> {
        let first = authManager.isLoading
        let second = loadingProcess.asDriver(onErrorJustReturn: false)
        return Driver.merge(first, second)
    }
    
    func logOut() -> Single<Void> {
        return authManager.logOut()
    }
    
    func deleteAccount() -> Single<Void> {
        guard let user = authManager.currentUser else { return .error(CustomError(Constants.Alert.Messages.noUser)) }
        return authManager.deleteUser(user)
    }
    
    func fetchCurrentUser() -> Single<UserModel?> {
        guard let id = authManager.currentUser?.uid else { return .never() }
        return Single.create { [weak self] single in
            self?.loadingProcess.accept(true)
            self?.storeManager.get(id: id) { result in
                defer { self?.loadingProcess.accept(false) }
                switch result {
                case .success(let data):
                    let sections = self?.generateSections(using: .month) ?? []
                    self?.taskSectionsProcess.accept(sections)
                    single(.success(data))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func handleDateFromVissibleCell(_ date: Date?) {
        guard let date else { return }
        scrolledDateProcess.accept(date)
    }
    
    func handleSelectedDate(_ date: Date) {
        let sections = taskSectionsProcess.value
        for (sectionIndex, section) in sections.enumerated() {
            guard let rowIndex = section.items.firstIndex(where: { $0.reminderDate.isSameDay(as: date) } ) else { continue }
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            scrolledIndexPathProcess.accept(indexPath)
        }
    }
    
    func generateSections(using style: GroupingStyle) -> [TaskSectionModel] {
        let calendar = Calendar.current
        let randomTasks = generateRandomTasks()
        let groupedTasks = groupTasks(randomTasks, style: style, using: calendar)
        let dateFormatter = DateFormatter()
        
        let taskSections = groupedTasks.compactMap { (key, value) -> TaskSectionModel? in
            let header: String
            switch style {
            case .day:
                dateFormatter.setLocalizedDateFormatFromTemplate(.dayFormat)
                header = calendar.isDateInToday(key) ? Constants.HomeScreen.today : key.toString(dateFormatter)
            case .week:
                dateFormatter.setLocalizedDateFormatFromTemplate(.dayFormat)
                if let endOfWeek = calendar.date(byAdding: .day, value: 6, to: key) {
                    header = "\(key.toString(dateFormatter)) - \(endOfWeek.toString(dateFormatter))"
                } else {
                    return nil
                }
            case .month:
                dateFormatter.setLocalizedDateFormatFromTemplate(.monthFormat)
                header = key.toString(dateFormatter)
            case .year:
                dateFormatter.setLocalizedDateFormatFromTemplate(.yearFormat)
                header = key.toString(dateFormatter)
            }
            return TaskSectionModel(header: header, groupingStyle: style, items: value)
        }
        
        return taskSections
    }
    
    func loadData() { }
}

private extension HomeViewModel {
    
    func generateRandomTasks() -> [TaskModel] {
        let randomTasks = (0..<50).map { i -> TaskModel in
            let objectId = UUID().uuidString
            let title = "Task \(i + 1)"
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let description = String((20...150).map { _ in letters.randomElement()! })
            let priority: TaskProirity = [.low, .medium, .high].randomElement()!
            let reminderDate = Date().addingTimeInterval(Double.random(in: 1...259200000))
            let status: TaskStatus = [.toDo, .done].randomElement()!
            return TaskModel(objectId: objectId,
                             title: title,
                             description: description,
                             priority: priority,
                             reminderDate: reminderDate,
                             status: status)
        }
        
        randomTasks.sorted { $0.reminderDate > $1.reminderDate }.forEach { model in
            print(model.reminderDate)
        }
        
        return randomTasks.sorted { $0.reminderDate > $1.reminderDate }
        
    }
    
    func sectionDate(from date: Date, style: GroupingStyle, using calendar: Calendar) -> Date? {
        var components: Set<Calendar.Component>
        
        switch style {
        case .day:
            components = [.year, .month, .day]
        case .week:
            components = [.yearForWeekOfYear, .weekOfYear]
        case .month:
            components = [.year, .month]
        case .year:
            components = [.year]
        }
        
        return calendar.date(from: calendar.dateComponents(components, from: date))
    }
    
    func groupTasks(_ tasks: [TaskModel], style: GroupingStyle, using calendar: Calendar) -> [(key: Date, value: [TaskModel])] {
        var sections: [Date: [TaskModel]] = [:]
        
        for task in tasks {
            let date = task.reminderDate
            
            guard let sectionKey = sectionDate(from: date, style: style, using: calendar) else { continue }
            sections[sectionKey, default: []].append(task)
        }
        
        return sections.sorted { $0.key > $1.key }
    }
}

private extension String {
    
    static let dayFormat = "yyyyMMMMd"
    static let weekFormat = "yyyyMMMd"
    static let monthFormat = "yyyyMMMM"
    static let yearFormat = "yyyy"
}
