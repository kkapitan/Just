//
//  UIViewController+Common.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit
import PKHUD

extension UIViewController {
    func showError(_ error: Error?) {
        let alert = UIAlertController.errorAlert(error: error)
        present(alert, animated: true)
    }
    
    func showHud() {
        HUD.hide()
        HUD.show(.progress)
    }
    
    func hideHud() {
        HUD.hide()
    }
}

extension UIAlertController {
    static func errorAlert(error: Error?) -> UIAlertController {
        let title = "Ooops..."
        
        guard let error = error else {
            return errorAlert(title: title, message: "An error occured, please try again!")
        }
        
        return errorAlert(title: title, message: error.localizedDescription)
    }
    
    static func errorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        return alert
    }
}
