//
//  SettingsSwitchCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class SettingsSwitchCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var setting: Bool? {
        didSet {
            settingSwitch.isOn = setting ?? false
        }
    }
}
