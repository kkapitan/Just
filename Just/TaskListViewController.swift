//
//  TaskListViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    var tasks: [[Task]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: DashboardItemCell.self)
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        mock()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let task = tasks[indexPath.section][indexPath.row]
        let cell: DashboardItemCell = tableView.dequeue()
        
        cell.title = task.title
        cell.taskDescription = task.taskDescription
        cell.status = task.priority
        
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titleView = SectionTitleView.view
        titleView.title = title(forSection: section)
            
        return titleView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func title(forSection section: Int) -> String {
        switch section {
        case 0:
            return "RECENT"
        case 1:
            return "YESTERDAY"
        default:
            return "Unknown"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

extension TaskListViewController {
    func mock() {
        let task = Task(id: "1231", title: "Title2222", dueDate: Date(), priority: .high, taskDescription: "Vryasd asdopk asdkpas kdpoask sd kdaosd kaskd appp daspdk asopdkasp asda oasjdioj aosjda jsd jsaoidjaosj dasdoiajsod asjdoasidi jajsdoiasj jasjdjioaj asdasdasoijdoajojdaoid jsad jasjdj jasdj ojd iojoasdj")
        
        tasks = [
            [
                task,
                task,
                task,
                task,
                task,
                task
            ],
            [
                task,
                task,
                task,
                task
            ]
        ]
        
    }
}
