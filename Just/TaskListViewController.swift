//
//  TaskListViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit
import RealmSwift

final class TaskListViewController: UITableViewController {
    
    let dashboardInputView: DashboardInputView = {
        return .view
    }()

    let storage: TasksStorage = {
        return try! .init()
    }()
    
    var sections: [[Task]] {
        return [storage.tasks(false), storage.tasks(true)].filter { !$0.isEmpty }
    }
    
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: DashboardItemCell.self)
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupInputView()
        fetchLists()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let task = sections[indexPath.section][indexPath.row]
        let cell: DashboardItemCell = tableView.dequeue()
        
        cell.title = task.title
        cell.taskDescription = task.taskDescription
        cell.status = task.priority
        cell.isDone = task.isDone
        
        cell.editButton.addTarget(self, action: #selector(editAction(_:forEvent:)), for: .touchUpInside)
        cell.tickButton.addTarget(self, action: #selector(doneAction(_:forEvent:)), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titleView = SectionTitleView.view
        titleView.title = title(forSection: section)
            
        return titleView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    func fetchLists() {
        let service = ListService()
        
        service.fetchLists { [weak self] result in
            switch result {
            case .success(let lists):
                guard let list = lists.first else { return }
                
                service.fetchTasks(for: list) { result in
                    switch result {
                    case .success(let list):
                        try! self?.storage.add(list.tasks, update: true)
                        self?.tableView.reloadData()
                    case .failure(let error):
                        self?.showError(error)
                    }
                }
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    func createTask() {
        let service = TasksService()
        
        var form = TaskForm()
        form.title = dashboardInputView.text
        form.due = dashboardInputView.date
        form.listId = dashboardInputView.list?.id
        
        showHud()
        service.createTask(with: form) { [weak self] result in
            self?.hideHud()
            
            switch result {
            case .success(let task):
                try! self?.storage.add(task)
                
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showError(error)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        let settings = Wireframe.Main().settings()
        let navigationController = MainNavigationController(rootViewController: settings)
        
        present(navigationController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let task = sections[indexPath.section][indexPath.row]
        let taskDetails = Wireframe.Main().taskDetails()
        
        taskDetails.task = task
        
        navigationController?.pushViewController(taskDetails, animated: true)
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
        
        listPicker.onSelect = { [unowned self] list in
            self.dashboardInputView.list = list
        }
        
        presentPopover(listPicker, sourceView: sender, size: contentSize)
    }
    
    func clockButtonAction(sender: UIButton) {
        let datePicker = Wireframe.Main().datePicker()
        let contentSize = CGSize(width: 300, height: 250)
        
        datePicker.onPick = { [unowned self] date in
            self.dashboardInputView.date = date
        }
        
        datePicker.onClear = { [unowned self] in
            self.dashboardInputView.date = nil
        }
        
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
    func doneAction(_ sender: UIButton, forEvent: UIEvent) {
        guard let indexPath = tableView.indexPath(forEvent: forEvent) else { return }
        
        let task = sections[indexPath.section][indexPath.row]
        
        let service = TasksService()
        service.updateStatus(task: task) { [weak self] result in
            switch result {
            case .success(let updatedTask):
                try! self?.storage.add(updatedTask, update: true)
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    func editAction(_ sender: UIButton, forEvent: UIEvent) {
        guard let indexPath = tableView.indexPath(forEvent: forEvent) else { return }
        
        let task = sections[indexPath.section][indexPath.row]
        
        let taskDetails = Wireframe.Main().taskDetails()
        
        taskDetails.task = task
        taskDetails.enablesEdition = true
        
        navigationController?.pushViewController(taskDetails, animated: true)
    }
    
    func deleteAction(_ sender: UIButton, forEvent: UIEvent) {
        guard let indexPath = tableView.indexPath(forEvent: forEvent) else { return }

        let task = sections[indexPath.section][indexPath.row]
        
        let service = TasksService()
        service.deleteTask(task: task) { _ in }
        try! storage.remove(task)

        tableView.reloadData()
    }
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
        createTask()
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
