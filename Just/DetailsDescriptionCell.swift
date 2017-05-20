//
//  DetailsDescriptionCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DetailsDescriptionCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var taskDescription: String? {
        didSet {
            descriptionTextView.text = taskDescription
        }
    }
    
    var allowEditing: Bool = false {
        didSet {
            descriptionTextView.isEditable = allowEditing
        }
    }
}
