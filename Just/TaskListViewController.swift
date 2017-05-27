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
    
    func showListPickerPopover(_ button: UIButton) {
        let listPicker = Wireframe.Main().listPicker()
        let contentSize = CGSize(width: 184, height: 260)
        
        let list = dashboardInputView.viewModel.list.value
        listPicker.viewModel = ListPickerViewModel(list: list, allowAdding: false)
        
        listPicker
            .selected
            .bindTo(dashboardInputView.viewModel.list)
            .addDisposableTo(disposeBag)

        presentPopover(listPicker, sourceView: button, size: contentSize)
    }
    
    func showDatePickerPopover(_ button: UIButton) {
        let datePicker = Wireframe.Main().datePicker()
        let contentSize = CGSize(width: 300, height: 250)
        
        datePicker.selected.value = dashboardInputView.viewModel.date.value
        
        datePicker
            .selected
            .asObservable()
            .bindTo(dashboardInputView.viewModel.date)
            .addDisposableTo(disposeBag)
    
        presentPopover(datePicker, sourceView: button, size: contentSize)
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
        
        dashboardInputView
            .listButton.rx
            .tap
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.showListPickerPopover(self.dashboardInputView.listButton)
            })
            .addDisposableTo(disposeBag)
        
        dashboardInputView
            .clockButton.rx
            .tap
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.showDatePickerPopover(self.dashboardInputView.clockButton)
            })
            .addDisposableTo(disposeBag)
        
        dashboardInputView
            .inputTextField.rx
            .controlEvent(.editingDidBegin)
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.editingDidBegin()
            })
            .addDisposableTo(disposeBag)
        
        dashboardInputView
            .inputTextField.rx
            .controlEvent(.editingDidEnd)
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.editingDidEnd()
            })
            .addDisposableTo(disposeBag)
        
        dashboardInputView
            .inputTextField.rx
            .controlEvent(.editingDidEndOnExit)
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.createTask()
            })
            .addDisposableTo(disposeBag)
    }
}

extension TaskListViewController {
    
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
    
    func editingDidBegin() {
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
    
    func editingDidEnd() {
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
        dashboardInputView.inputTextField.resignFirstResponder()
    }
}

extension TaskListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
