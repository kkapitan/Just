//
//  TaskDetailsViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class TaskDetailsViewController: UITableViewController {
    
    var enablesEdition: Bool = false
    var task: Task!
    
    func enableEdition(_ edition: Bool) {
        enablesEdition = edition
        tableView.reloadData()
        
        if enablesEdition {
            let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
            
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
            
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = saveButton
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func saveAction() {
        let service = TasksService()
        let form = TaskForm()
        
        service.updateTask(task: task, with: form) { [weak self] result in
            switch result {
            case .success(let updatedTask):
                self?.task = updatedTask
                self?.enableEdition(false)
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    func cancelAction() {
        enableEdition(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: DetailsDescriptionCell.self)
        tableView.registerNib(for: DetailsStatusCell.self)
        tableView.registerNib(for: DetailsActionCell.self)
        tableView.registerNib(for: DetailsTitleCell.self)
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return enablesEdition ? 3 : 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell: DetailsTitleCell = tableView.dequeue()
            cell.title = task.title
            cell.allowEditing = enablesEdition
            
            return cell
        case 1:
            let cell: DetailsStatusCell = tableView.dequeue()
            cell.date = task.dueDate
            cell.allowEditing = enablesEdition
            
            return cell
        case 2:
            let cell: DetailsDescriptionCell = tableView.dequeue()
            cell.taskDescription = task.taskDescription
            
            return cell
        case 3:
            let cell: DetailsActionCell = tableView.dequeue()
            cell.editButton.addTarget(self, action: #selector(editAction(_:forEvent:)), for: .touchUpInside)
            cell.tickButton.addTarget(self, action: #selector(doneAction(_:forEvent:)), for: .touchUpInside)
            cell.trashButton.addTarget(self, action: #selector(deleteAction(_:forEvent:)), for: .touchUpInside)
            return cell
        default:
            fatalError("Wrong section id")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titleView = SectionTitleView.view
        titleView.title = title(forSection: section)
        
        return titleView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func doneAction(_ sender: UIButton, forEvent: UIEvent) {
        
        let service = TasksService()
        service.updateStatus(task: task) { [weak self] result in
            switch result {
            case .success(let updatedTask):
                self?.task = updatedTask
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    func editAction(_ sender: UIButton, forEvent: UIEvent) {
        enableEdition(true)
    }
    
    func deleteAction(_ sender: UIButton, forEvent: UIEvent) {
        let service = TasksService()
        service.deleteTask(task: task) { _ in }
        
        navigationController?.popViewController(animated: true)
    }
}
