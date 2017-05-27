//
//  TaskDetailsViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

final class TaskDetailsViewController: UITableViewController, UITextViewDelegate {
    
    let disposeBag = DisposeBag()
    
    var task: Task!
    var viewModel: TaskDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TaskDetailsViewModel(task: task)
        
        tableView.registerNib(for: DetailsDescriptionCell.self)
        tableView.registerNib(for: DetailsStatusCell.self)
        tableView.registerNib(for: DetailsActionCell.self)
        tableView.registerNib(for: DetailsTitleCell.self)
        
        tableView.delegate = viewModel
        tableView.dataSource = nil
    
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupBindings()
    }
    
    func setupBindings() {
        
        viewModel
            .enablesEdition
            .asObservable()
            .subscribe(onNext: { [unowned self] edit in
                if edit {
                    let saveButton = UIBarButtonItem(title: "Save", style: .done, target: nil, action: nil)
                    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
                    
                    cancelButton.rx
                        .tap
                        .asObservable()
                        .map { false }
                        .bindTo(self.viewModel.enablesEdition)
                        .addDisposableTo(self.disposeBag)
                    
                    saveButton.rx
                        .tap
                        .asObservable()
                        .flatMapLatest(self.viewModel.saveDetails)
                        .bindTo(self.viewModel.actionResult)
                        .addDisposableTo(self.disposeBag)
                    
                    self.navigationItem.leftBarButtonItem = cancelButton
                    self.navigationItem.rightBarButtonItem = saveButton
                } else {
                    self.navigationItem.leftBarButtonItem = nil
                    self.navigationItem.rightBarButtonItem = nil
                }
                
                self.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
        
        viewModel
            .sections()
            .bindTo(tableView.rx.items(dataSource: viewModel.dataSource))
            .addDisposableTo(disposeBag)
        
        viewModel
            .actionResult
            .subscribe(onNext: { [unowned self] result in
                self.hideHud()
                
                switch result {
                case .success(.delete), .failure(.delete, _):
                    self.navigationController?.popViewController(animated: true)
                case .failure(_, let error):
                    self.showError(error)
                default:
                    self.tableView.reloadData()
                }
            })
            .addDisposableTo(disposeBag)
    }
}
