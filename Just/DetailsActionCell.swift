//
//  DetailsActionCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DetailsActionCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    
    var isDone: Bool? {
        didSet {
            let image = isDone.flatMap {
                $0 ? UIImage(named: "cross_button_ic") : UIImage(named: "tick_button_ic")
            }
            
            tickButton.setImage(image, for: .normal)
        }
    }
    
}
