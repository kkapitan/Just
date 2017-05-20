//
//  DatePicker.swift
//  Just
//
//  Created by Krzysztof Kapitan on 20.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DatePicker: UIDatePicker {
    
    typealias SelectionBlock = (Date) -> ()
    
    var onSelect: SelectionBlock?
    
    init() {
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func valueChanged(_ picker: UIDatePicker) {
        onSelect?(date)
    }
}

