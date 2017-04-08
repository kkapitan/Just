//
//  DetailsTitleCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DetailsTitleCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
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
}
