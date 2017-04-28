//
//  ListPickerViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class ListPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var lists: [List] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.registerNib(for: ListEntryCell.self)
        
        tableView.estimatedRowHeight = 53.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = lists[indexPath.row]
        
        //let cell: ListEntryCell = tableView.dequeue()
        //cell.name = list.name
            
        //return cell
        return UITableViewCell()
    }
    
    @IBAction func addButtonAction() {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }

}
