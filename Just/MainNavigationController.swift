//
//  MainNavigationController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        navigationBar.setBackgroundImage(UIImage.from(color: .purple), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        
        navigationBar.tintColor = .white
        
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOpacity = 0.5
        navigationBar.layer.shadowOffset = CGSize.zero
        navigationBar.layer.shadowRadius = 1.0
        navigationBar.layer.shadowPath = UIBezierPath(rect: navigationBar.bounds).cgPath
        
        delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

fileprivate extension UIImage {
    
    static func from(color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
}
