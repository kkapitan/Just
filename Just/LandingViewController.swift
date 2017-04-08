//
//  LandingViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class LandingViewController: UIViewController {
    
    @IBAction func signInButtonAction(_ sender: UIButton) {
        let register = Wireframe.Main().login()
        navigationController?.pushViewController(register, animated: true)
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        let register = Wireframe.Main().register()
        navigationController?.pushViewController(register, animated: true)
    }
}

