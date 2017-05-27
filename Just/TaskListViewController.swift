//
//  TaskListViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit
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
            
//            cell.deleteButton.rx
//                .tap
//                .asObservable()
//                .map { item }
//                .flatMap(self.deleteAction(task:))
//                .bindTo(self.actionResult)
//                .addDisposableTo(self.disposeBag)
//            
//            cell.tickButton.rx
//                .tap
//                .asObservable()
//                .map { item }
//                .flatMap(self.doneAction(task:))
//                .bindTo(self.actionResult)
//                .addDisposableTo(self.disposeBag)
//            
//            cell.editButton.rx
//                .tap
//                .asObservable()
//                .map { item }
//                .flatMap(self.editAction(task:))
//                .bindTo(self.actionResult)
//                .addDisposableTo(self.disposeBag)
            
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

final class TaskListViewController: UITableViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let dashboardInputView: DashboardInputView = {
        return .view
    }()
    
    var viewModel: TaskListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: DashboardItemCell.self)
        
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = nil
        tableView.delegate = viewModel
        
        setupInputView()
        setupBindings()
    }
    
    func setupBindings() {
        
        tableView.rx
            .modelSelected(Task.self)
            .subscribe(onNext: { [unowned self] task in
                let taskDetails = Wireframe.Main().taskDetails()
                
                taskDetails.task = task
                
                self.navigationController?.pushViewController(taskDetails, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        viewModel
            .sections()
            .bindTo(tableView.rx.items(dataSource: viewModel.dataSource))
            .addDisposableTo(disposeBag)
        
        viewModel
            .actionResult
            .asObserver()
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .success(.edit(let task)):
                    
                    let taskDetails = Wireframe.Main().taskDetails()
                    taskDetails.task = task
                    
                    self.navigationController?.pushViewController(taskDetails, animated: true)
            
                case .failure(_, let error):
                    self.showError(error)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
        dashboardInputView
            .viewModel
            .date
            .asObservable()
            .bindTo(viewModel.date)
            .addDisposableTo(disposeBag)
        
        dashboardInputView
            .viewModel
            .list
            .asObservable()
            .bindTo(viewModel.pickedList)
            .addDisposableTo(disposeBag)
        
        dashboardInputView
            .viewModel
            .text
            .asObservable()
            .bindTo(viewModel.title)
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func listsButtonAction(_ sender: Any) {
        let listPicker = Wireframe.Main().listPicker()
        
        listPicker.viewModel = ListPickerViewModel(list: viewModel.list.value, allowAdding: true)
        
        listPicker
            .selected
            .bindTo(viewModel.list)
            .addDisposableTo(disposeBag)
        
        present(listPicker, animated: true)
    }
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        let settings = Wireframe.Main().settings()
        let navigationController = MainNavigationController(rootViewController: settings)
        
        present(navigationController, animated: true)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return dashboardInputView
    }
    
    func listButtonAction(sender: UIButton) {
        let listPicker = Wireframe.Main().listPicker()
        let contentSize = CGSize(width: 184, height: 260)
        
        let list = dashboardInputView.viewModel.list.value
        listPicker.viewModel = ListPickerViewModel(list: list, allowAdding: false)
        
        listPicker
            .selected
            .bindTo(dashboardInputView.viewModel.list)
            .addDisposableTo(disposeBag)

        presentPopover(listPicker, sourceView: sender, size: contentSize)
    }
    
    func clockButtonAction(sender: UIButton) {
        let datePicker = Wireframe.Main().datePicker()
        let contentSize = CGSize(width: 300, height: 250)
        
        datePicker.selected.value = dashboardInputView.viewModel.date.value
        
        datePicker
            .selected
            .asObservable()
            .bindTo(dashboardInputView.viewModel.date)
            .addDisposableTo(disposeBag)
    
        presentPopover(datePicker, sourceView: sender, size: contentSize)
    }
    
    func presentPopover(_ popover: UIViewController, sourceView: UIView, size: CGSize) {
        popover.modalPresentationStyle = .popover
        popover.preferredContentSize = size
        
        let popoverController = popover.popoverPresentationController
        
        popoverController?.sourceRect = sourceView.bounds
        popoverController?.sourceView = sourceView
        popoverController?.delegate = self
        popoverController?.permittedArrowDirections = .init(rawValue: 0)
        
        present(popover, animated: true)
    }

    func setupInputView() {
        dashboardInputView.listButton
            .addTarget(self, action: #selector(listButtonAction), for: .touchUpInside)
        
        dashboardInputView.clockButton
            .addTarget(self, action: #selector(clockButtonAction), for: .touchUpInside)
        
        dashboardInputView.inputTextField.delegate = self
    }
}

extension TaskListViewController {

}

extension TaskListViewController: UITextFieldDelegate {
    
    var overlayView: UIView {
        let tag = 100
        
        return view.viewWithTag(tag) ?? {
            let overlayView = UIView()
            
            overlayView.tag = tag
            overlayView.frame = self.view.bounds
            overlayView.backgroundColor = .overlayGray
            
            return overlayView
        }()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dashboardInputView.activate()
        dashboardInputView.viewModel.list.value = viewModel.list.value
        
        tableView.isScrollEnabled = false
        
        self.view.addSubview(overlayView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapAction))
        self.overlayView.addGestureRecognizer(tapGesture)
        
        overlayView.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.overlayView.alpha = 0.6
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dashboardInputView.deactivate()
        tableView.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView.alpha = 0.0
        }) { _ in
            self.overlayView.removeFromSuperview()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.createTask()
        return true
    }
    
    func overlayTapAction() {
        tableView.isScrollEnabled = true
        dashboardInputView.inputTextField.resignFirstResponder()
    }
}

extension TaskListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
