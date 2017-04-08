//
//  SectionTitleView.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class SectionTitleView: UIView {
    @IBOutlet weak  var titleLabel: UILabel!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
}

extension SectionTitleView : NibLoadable {}

