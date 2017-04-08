//
//  TableView+Events.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

extension UITableView {
    func indexPath(forEvent event: UIEvent) -> IndexPath? {
        return event
            .allTouches?
            .first
            .flatMap { $0.location(in: self) }
            .flatMap { indexPathForRow(at: $0) }
    }
}

