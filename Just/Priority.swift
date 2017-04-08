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
}
