//
//  DetailsStatusCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DetailsStatusCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var status: Priority? {
        didSet {
            statusLabel.text = status?.description
        }
    }
    
    var date: Date? {
        didSet {
            let formatter = DateFormatter.full
            dateLabel.text = formatter.string(for: date)
        }
    }
}
