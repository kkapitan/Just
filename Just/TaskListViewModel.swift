//
//  TaskListViewModel.swift
//  Just
//
//  Created by Krzysztof Kapitan on 28.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

import RealmSwift
import RxSwift
import RxDataSources

final class TaskListViewModel: NSObject, UITableViewDelegate {
    
    enum Action {
        case fetch
        case delete
        case update
        case create
        case edit(Task)
    }
    
    enum ActionResult {
        case success(Action)
        case failure(Action, Error?)
    }
    
    typealias Section = SectionModel<String, Task>
    
    fileprivate let storage: TasksStorage = {
        return try! .init()
    }()
    
    fileprivate let tasksService: TasksService = {
        return .init()
    }()
    
    fileprivate let listsService: ListService = {
        return .init()
    }()
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let taskForm = Variable<TaskForm?>(nil)
    
    let title = Variable<String?>(nil)
    let pickedList = Variable<List?>(nil)
    let date = Variable<Date?>(nil)
    
    let dataSource = RxTableViewSectionedReloadDataSource<Section>()
    let list: Variable<List>
    
    let actionResult = PublishSubject<ActionResult>()
    
    init(list: List) {
        self.list = Variable(list)
        
        super.init()
        
        prepareTaskForm()
        prepareDataSource()
    }
    
    func prepareTaskForm() {
        Observable.combineLatest(
            title.asObservable().filterNil(),
            pickedList.asObservable().filterNil(),
            date.asObservable()
        ) { (title, list, due) -> TaskForm in
            
            var form = TaskForm()
            form.title = title
            form.listId = list.id
            form.due = due
            
            return form
            }
            .bindTo(taskForm)
            .addDisposableTo(disposeBag)
    }
    
    func prepareDataSource() {
        dataSource.configureCell = { [unowned self] _, tableView, _, item in
            
            let cell: DashboardItemCell = tableView.dequeue()
            
            cell.title = item.title
            cell.taskDescription = item.taskDescription
            cell.status = item.priority
            cell.isDone = item.isDone
            
            cell.deleteButton.rx
                .tap
                .asObservable()
                .map { item }
                .flatMap(self.deleteAction(task:))
                .bindTo(self.actionResult)
                .addDisposableTo(cell.disposeBag)
            
            cell.tickButton.rx
                .tap
                .asObservable()
                .map { item }
                .flatMap(self.doneAction(task:))
                .bindTo(self.actionResult)
                .addDisposableTo(cell.disposeBag)
            
            cell.editButton.rx
                .tap
                .asObservable()
                .map { item }
                .flatMap(self.editAction(task:))
                .bindTo(self.actionResult)
                .addDisposableTo(cell.disposeBag)
            
            return cell
        }
    }
    
    func sections() -> Observable<[Section]> {
        return list.asObservable().flatMap { [unowned self] list in
            return Observable.combineLatest(
                self.storage.tasks(for: list, done: false),
                self.storage.tasks(for: list, done: true)
            ) { (notDone, done) -> [Section] in
                
                return [
                    Section(model: "", items: notDone),
                    Section(model: "", items: done)
                ]
            }
        }
    }
    
    func createTask() {
        guard let form = taskForm.value else {
            actionResult.onNext(.failure(.create, nil))
            return
        }
        
        tasksService.createTask(with: form)
            .map { [unowned self] result in
                switch result {
                case .success(let task):
                    try! self.storage.add(task)
                    
                    return .success(.create)
                case .failure(let error):
                    return .failure(.create, error)
                }
            }
            .bindTo(actionResult)
            .addDisposableTo(disposeBag)
    }
    
    func fetchTasks(list: List) -> Observable<ActionResult> {
        return listsService
            .fetchTasks(for: list)
            .map { [unowned self] result in
                switch result {
                case .success(let list):
                    try! self.storage.add(list.tasks, update: true)
                    return .success(.fetch)
                case .failure(let error):
                    return .failure(.fetch, error)
                }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titleView = SectionTitleView.view
        titleView.title = title(forSection: section)
        
        return titleView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func title(forSection section: Int) -> String {
        switch section {
        case 0:
            return "RECENT"
        case 1:
            return "DONE"
        default:
            fatalError("Wrong section id")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func doneAction(task: Task) -> Observable<ActionResult> {
        
        return tasksService
            .updateStatus(task: task)
            .map { [unowned self] result in
                switch result {
                case .success(let updatedTask):
                    try! self.storage.add(updatedTask, update: true)
                    
                    return .success(.update)
                case .failure(let error):
                    return .failure(.update, error)
                }
        }
    }
    
    func editAction(task: Task) -> Observable<ActionResult> {
        return Observable.just(.success(.edit(task)))
    }
    
    func deleteAction(task: Task) -> Observable<ActionResult> {
        try! storage.remove(task)
        
        return tasksService
            .deleteTask(task: task)
            .map {
                switch $0 {
                case .success:
                    return .success(.delete)
                case .failure(let error):
                    return .failure(.delete, error)
                }
        }
    }
}
