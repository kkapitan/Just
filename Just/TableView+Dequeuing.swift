//
//  TableView+Dequeuing.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

extension UITableView {
    func registerClass<Cell: UITableViewCell>(for cellClass: Cell.Type) where Cell: Reusable {
        register(cellClass, forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func registerNib<Cell: UITableViewCell>(for: Cell.Type) where Cell: Reusable & NibLoadable {
        register(Cell.nib, forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeue<Cell: UITableViewCell>() -> Cell where Cell: Reusable {
        return self.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as! Cell
    }
}
