//
//  DashboardItemCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DashboardItemCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var accessoryImage: UIImage? {
        didSet {
            accessoryImageView.image = accessoryImage
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var status: String? {
        didSet {
            statusLabel.text = status
        }
    }
    
    var taskDescription: String? {
        didSet {
            descriptionLabel.text = taskDescription
        }
    }
}
