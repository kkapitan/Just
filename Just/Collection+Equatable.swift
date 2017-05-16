//
//  Collection+Equatable.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(element: Element) {
        guard let index = index(of: element) else { return }

        self.remove(at: index)
    }
}
