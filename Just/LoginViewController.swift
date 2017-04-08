//
//  LoginViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameOrEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editingChanged(nil)
    }
    
    @IBAction func editingChanged(_ sender: UITextField?) {
        let valid = isFormValid()
        
        continueButton.isEnabled = valid
        continueButton.backgroundColor = valid ? .buttonGreen : .buttonGray
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        let usernameOrEmail = usernameOrEmailTextField.text!
        let password = passwordTextField.text!
        
        let taskList = Wireframe.Main().taskList()
        let navigationController = MainNavigationController(rootViewController: taskList)
        
        present(navigationController, animated: true)
    }
    
    func isFormValid() -> Bool {
        let usernameOrEmail = usernameOrEmailTextField.text!
        let password = passwordTextField.text!
        
        return (Validations.isValid(email: usernameOrEmail)
            || Validations.isValid(username: usernameOrEmail))
            && Validations.isValid(password: password)
    }

    
}
