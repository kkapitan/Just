//
//  TaskDetailsViewModel.swift
//  Just
//
//  Created by Krzysztof Kapitan on 27.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

final class TaskDetailsViewModel: NSObject, UITableViewDelegate {
    
    fileprivate let service: TasksService = {
        return .init()
    }()
    
    fileprivate let storage: TasksStorage = {
        return try! .init()
    }()
    
    fileprivate let priorityPicker: PickerView = {
        return  PickerView(items: Priority.all)
    }()
    
    fileprivate let datePicker: UIDatePicker = {
        return .init()
    }()
    
    fileprivate let taskForm = Variable<TaskForm?>(nil)
    fileprivate let items = Variable<[Section]>([])
    
    fileprivate let task: Variable<Task>
    fileprivate let disposeBag = DisposeBag()
    
    enum Action {
        case delete
        case update
        case save
    }
    
    enum ActionResult {
        case success(Action)
        case failure(Action, Error?)
    }
    
    enum TaskEntry {
        case title(String)
        case description(String?)
        case status(Priority, Date?)
        case actions(Bool)
    }
    
    typealias Section = SectionModel<String, (TaskEntry, Bool)>
    
    // Input
    let enablesEdition = Variable<Bool>(false)
    
    let priority = Variable<Priority?>(nil)
    let date = Variable<Date?>(nil)
    
    let title = Variable<String?>(nil)
    let taskDescription = Variable<String?>(nil)
    
    let listId = Variable<Int?>(nil)
    let isDone = Variable<Bool?>(nil)
    
    // Output
    let actionResult = PublishSubject<ActionResult>()
    let dataSource = RxTableViewSectionedReloadDataSource<Section>()
    
    init(task: Task) {
        self.task = Variable(task)
        
        super.init()
        
        fetchDetails()
        prepareProperties()
        
        prepareFormObservable()
        prepareItemsObservable()
        
        prepareDataSource()
    }
    
    fileprivate func prepareProperties() {
        enablesEdition.asObservable()
            .map { _ in self.task.value }
            .bindTo(task)
            .addDisposableTo(disposeBag)
        
        task.asObservable()
            .map { $0.title }
            .bindTo(title)
            .addDisposableTo(disposeBag)
        
        task.asObservable()
            .map { $0.taskDescription }
            .bindTo(taskDescription)
            .addDisposableTo(disposeBag)
        
        task.asObservable()
            .map { $0.dueDate }
            .bindTo(date)
            .addDisposableTo(disposeBag)
        
        task.asObservable()
            .map { $0.priority }
            .bindTo(priority)
            .addDisposableTo(disposeBag)
        
        task.asObservable()
            .map { $0.isDone }
            .bindTo(isDone)
            .addDisposableTo(disposeBag)
        
        task.asObservable()
            .map { $0.listId }
            .bindTo(listId)
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func prepareFormObservable() {
        
        Observable.combineLatest(
            title.asObservable().filterNil(),
            priority.asObservable().filterNil(),
            date.asObservable(),
            taskDescription.asObservable(),
            listId.asObservable().filterNil(),
            isDone.asObservable().filterNil()
        ) {
            var form = TaskForm()
            form.title = $0
            form.priority = $1
            form.due = $2
            form.description = $3
            form.listId = $4
            form.isDone = $5
            
            return form
            }
            .bindTo(taskForm)
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func prepareItemsObservable() {
        
        Observable.combineLatest(
            task.asObservable(),
            enablesEdition.asObservable()) { (task, edit) -> [(TaskDetailsViewModel.TaskEntry, Bool)] in
                
                return [
                    (.title(task.title), edit),
                    (.status(task.priority, task.dueDate), edit),
                    (.description(task.taskDescription), edit),
                    (.actions(task.isDone), edit),
                    ].filter {
                        if case .actions = $0.0 { return !edit }
                        
                        return true
                }
            }.map {
                $0.map { Section(model: "", items: [$0]) }
            }
            .bindTo(items)
            .addDisposableTo(disposeBag)
    }
    
    func sections() -> Observable<[Section]> {
        return items.asObservable()
    }
    
    func prepareDataSource() {
        
        dataSource.configureCell = { [unowned self] _, tableView, _, item in
            switch item {
            case (.title(let title), let editing):
                let cell: DetailsTitleCell = tableView.dequeue()
                
                cell.title = title
                cell.allowEditing = editing
                
                self.title
                    .asObservable()
                    .bindTo(cell.titleTextField.rx.text)
                    .addDisposableTo(self.disposeBag)
                
                cell.titleTextField.rx
                    .text
                    .asObservable()
                    .bindTo(self.title)
                    .addDisposableTo(self.disposeBag)
                
                return cell
            case (.description(let description), let editing):
                let cell: DetailsDescriptionCell = tableView.dequeue()
                
                cell.taskDescription = description
                cell.allowEditing = editing
                
                cell.descriptionTextView.rx
                    .text
                    .asObservable()
                    .bindTo(self.taskDescription)
                    .addDisposableTo(self.disposeBag)
                
                self.taskDescription
                    .asObservable()
                    .bindTo(cell.descriptionTextView.rx.text)
                    .addDisposableTo(self.disposeBag)
                
                return cell
            case (.status(let priority, let date), let editing):
                let cell: DetailsStatusCell = tableView.dequeue()
                
                cell.allowEditing = editing
                cell.date = date
                cell.status = priority
                
                self.priority
                    .asObservable()
                    .subscribe(onNext: { cell.status = $0 })
                    .addDisposableTo(self.disposeBag)
                
                self.priorityPicker
                    .selected
                    .bindTo(self.priority)
                    .addDisposableTo(self.disposeBag)
                
                self.date
                    .asObservable()
                    .subscribe(onNext: { cell.date = $0 })
                    .addDisposableTo(self.disposeBag)
                
                self.datePicker.rx
                    .date
                    .bindTo(self.date)
                    .addDisposableTo(self.disposeBag)
                
                self.date
                    .asObservable()
                    .filterNil()
                    .bindTo(self.datePicker.rx.date)
                    .addDisposableTo(self.disposeBag)
                
                cell.statusTextField.inputView = self.priorityPicker
                cell.dateTextField.inputView = self.datePicker
                
                return cell
            case (.actions(let done), _):
                let cell: DetailsActionCell = tableView.dequeue()
                cell.isDone = done
                
                cell.tickButton.rx
                    .tap
                    .asObservable()
                    .flatMap { _ in return self.updateStatus() }
                    .bindTo(self.actionResult)
                    .addDisposableTo(self.disposeBag)
                
                cell.trashButton.rx
                    .tap
                    .asObservable()
                    .flatMap { _ in return self.deleteTask() }
                    .bindTo(self.actionResult)
                    .addDisposableTo(self.disposeBag)
                
                cell.editButton.rx
                    .tap
                    .asObservable()
                    .subscribe(onNext: { [unowned self] in
                        self.enablesEdition.value = true
                    })
                    .addDisposableTo(self.disposeBag)
                
                return cell
            }
        }
    }
    
    func fetchDetails() {
        service.fetchTaskDetails(for: task.value).map { (result) -> Task? in
            guard case .success(let task) = result else { return nil }
            
            return task
            }
            .filterNil()
            .bindTo(task)
            .addDisposableTo(disposeBag)
    }
    
    func saveDetails() -> Observable<ActionResult> {
        guard let form = taskForm.value else {
            return Observable.just(.failure(.save, nil))
        }
        
        return service.updateTask(task: task.value, with: form).map { [unowned self] in
            switch $0 {
            case .success(let task):
                try self.storage.add(task, update: true)
                
                self.task.value = task
                self.enablesEdition.value = false
                
                return .success(.save)
            case .failure(let error):
                return .failure(.save, error)
            }
        }
    }
    
    func deleteTask() -> Observable<ActionResult> {
        try! self.storage.remove(task.value)
        
        return service.deleteTask(task: task.value).map {
            switch $0 {
            case .success:
                return .success(.delete)
            case .failure(let error):
                return .failure(.delete, error)
            }
        }
    }
    
    func updateStatus() -> Observable<ActionResult> {
        return service.updateStatus(task: task.value).map { [unowned self] in
            switch $0 {
            case .success(let task):
                try self.storage.add(task, update: true)
                
                self.task.value = task
                
                return .success(.update)
            case .failure(let error):
                return .failure(.update, error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titleView = SectionTitleView.view
        titleView.title = title(forSection: section)
        
        return titleView
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 62
        case 1:
            return 40
        case 2:
            return 92
        case 3:
            return 38
        default:
            fatalError("Wrong section id")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func title(forSection section: Int) -> String {
        switch section {
        case 0:
            return "TITLE"
        case 1:
            return "DEADLINE"
        case 2:
            return "DESCRIPTION"
        case 3:
            return "ACTIONS"
        default:
            fatalError("Wrong section id")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
