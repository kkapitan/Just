//
//  ListPickerViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class ListPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    typealias SelectAction = (List) -> ()
    var onSelect: SelectAction?
    
    @IBOutlet weak var tableView: UITableView!
    
    var lists: [List] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: ListEntryCell.self)
        tableView.estimatedRowHeight = 53.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchLists()
    }
    
    func fetchLists() {
        let service = ListService()
        
        service.fetchLists { [weak self] result in
            switch result {
            case .success(let lists):
                self?.lists = lists
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = lists[indexPath.row]
        
        let cell: ListEntryCell = tableView.dequeue()
        cell.title = list.name
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(lists[indexPath.row])
    }
    
    @IBAction func addButtonAction() {
        let alert = UIAlertController(title: "New list", message: "Enter name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.becomeFirstResponder()
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let name = alert.textFields?.first?.text else { return }
            
            let list = List(id: 0, name: name, tasks: [])
            
            self.lists.append(list)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
