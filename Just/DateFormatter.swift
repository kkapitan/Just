//
//  DateFormatter.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

extension DateFormatter {
    enum Format {
        case full
        
        var string: String {
            switch self {
            case .full:
                return "dd MMMM yyyy hh:mm"
            }
        }
    }
    
    convenience init(format: Format) {
        self.init()
        dateFormat = format.string
    }
}

extension DateFormatter {
    
    static let full: DateFormatter = {
        return .init(format: .full)
    }()
    
}
