//
//  TaskListViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    let dashboardInputView: DashboardInputView = {
        return .view
    }()

    var tasks: [[Task]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: DashboardItemCell.self)
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        mock()
        setupInputView()
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
        return 30.0
    }
    
    func title(forSection section: Int) -> String {
        switch section {
        case 0:
            return "RECENT"
        case 1:
            return "YESTERDAY"
        default:
            fatalError("Wrong section id")
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
        
        let task = tasks[indexPath.section][indexPath.row]
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
        
        dashboardInputView.inputTextView.delegate = self
    }
    
}

extension TaskListViewController: UITextViewDelegate {
    
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        dashboardInputView.deactivate()
        tableView.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView.alpha = 0.0
        }) { _ in
            self.overlayView.removeFromSuperview()
        }
    }
    
    func overlayTapAction() {
        tableView.isScrollEnabled = true
        dashboardInputView.inputTextView.resignFirstResponder()
    }
}

extension TaskListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension TaskListViewController {
    func mock() {
        let task = Task(id: "1231", title: "Title2222", dueDate: Date(), priority: .high, taskDescription: "Vryasd asdopk asdkpas kdpoask sd kdaosd kaskd appp daspdk asopdkasp asda oasjdioj aosjda jsd jsaoidjaosj dasdoiajsod asjdoasidi jajsdoiasj jasjdjioaj asdasdasoijdoajojdaoid jsad jasjdj jasdj ojd iojoasdj", isDone: false)
        
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
