//
//  ListPickerViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

final class ListPickerViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ListPickerViewModel!
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: ListEntryCell.self)
        
        tableView.estimatedRowHeight = 53.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = viewModel
        tableView.dataSource = nil
        
        setupBindings()
    }
    
    var selected: Observable<List> {
        return viewModel
            .selected
            .asObservable()
            .filterNil()
    }
    
    func setupBindings() {
        
        viewModel
            .allowAdding
            .asObservable()
            .map { !$0 }
            .bindTo(addButton.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(List.self)
            .bindTo(viewModel.selected)
            .addDisposableTo(disposeBag)
        
        viewModel
            .sections()
            .bindTo(tableView.rx.items(dataSource: viewModel.dataSource))
            .addDisposableTo(disposeBag)
        
        cancelButton.rx
            .tap
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .addDisposableTo(disposeBag)
        
        addButton.rx
            .tap
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.showAddListAlert()
            })
            .addDisposableTo(disposeBag)
        
        viewModel
            .selectedIndexPath
            .asObservable()
            .filterNil()
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.selectRow(at: indexPath)
            })
            .addDisposableTo(disposeBag)
    }

    func showAddListAlert() {
        let alert = UIAlertController(title: "New list", message: "Enter name", preferredStyle: .alert)
        
        alert.addTextField {
            $0.rx.text
                .bindTo(self.viewModel.name)
                .addDisposableTo(self.disposeBag)
            
            $0.becomeFirstResponder()
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.viewModel.addList()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension UITableView {
    func selectRow(at indexPath: IndexPath, animated: Bool = false) {
        selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    func reloadDataPreservingSelection() {
        let indexPath = indexPathForSelectedRow
        reloadData()
        selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
}
