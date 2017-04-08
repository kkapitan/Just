//
//  Instantiator.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class Instantiatior {
    let wireframe: StoryboardWireframe
    
    init(wireframe: StoryboardWireframe) {
        self.wireframe = wireframe
    }
    
    func identifiable<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        return wireframe.storyboard.instantiateViewController(withIdentifier: T.identifier) as! T
    }
    
    func initial<T: UIViewController>() -> T {
        return wireframe.storyboard.instantiateInitialViewController() as! T
    }
}
