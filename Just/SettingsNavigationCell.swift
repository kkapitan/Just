//
//  SettingsNavigationCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class SettingsNavigationCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel!

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
}
