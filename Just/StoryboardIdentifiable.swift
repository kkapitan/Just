//
//  StoryboardIdentifiable.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    static var identifier: String { get }
}

extension StoryboardIdentifiable {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController : StoryboardIdentifiable {}
