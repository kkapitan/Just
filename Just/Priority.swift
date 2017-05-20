//
//  Priotity.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

enum Priority: String {
    case high, low, medium, urgent
    
    var description: String {
        return "\(rawValue) Priority".capitalized
    }
    
    static var all: [Priority] {
        return [.urgent, .high, .medium, .low]
    }
}

extension Priority: PickerItem {
    var title: String {
        return description
    }
}
