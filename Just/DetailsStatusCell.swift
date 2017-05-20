//
//  DetailsStatusCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DetailsStatusCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    var status: Priority? {
        didSet {
            statusTextField.text = status?.description
        }
    }
    
    var date: Date? {
        didSet {
            let formatter = DateFormatter.full
            dateTextField.text = formatter.string(for: date) ?? "N/A"
        }
    }
    
    var allowEditing: Bool = false {
        didSet {
            statusTextField.isUserInteractionEnabled = allowEditing
            dateTextField.isUserInteractionEnabled = allowEditing
        }
    }
}
