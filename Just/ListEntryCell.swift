//
//  ListEntryCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 07.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class ListEntryCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        tickImageView.isHidden = !selected
    }
}
