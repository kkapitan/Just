//
//  RegistrationViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmationTextField: UITextField!
    
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
      
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmation = confirmationTextField.text!
        
        let taskList = Wireframe.Main().taskList()
        let navigationController = MainNavigationController(rootViewController: taskList)
        
        present(navigationController, animated: true)
    }
    
    func isFormValid() -> Bool {
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmation = confirmationTextField.text!
        
        return Validations.isValid(email: email)
            && Validations.isValid(username: username)
            && Validations.isValid(confirmation: confirmation, of: password)
            && Validations.isValid(password: password)
    }
}
