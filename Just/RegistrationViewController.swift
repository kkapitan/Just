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
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var continueButton: UIButton!
    
    fileprivate let keyboard = Keyboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        hideKeyboardOnTap()
        
        editingChanged(nil)
    }
    
    @IBAction func editingChanged(_ sender: UITextField?) {
        let valid = isFormValid()
        
        continueButton.isEnabled = valid
        continueButton.backgroundColor = valid ? .buttonGreen : .buttonGray
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
    
    @IBAction func continueAction(_ sender: UIButton) {
      
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmation = confirmationTextField.text!
        
        let userForm = UserForm(username: username, email: email, password: password, confirmation: confirmation)
        let service = UserService()
        
        showProgress("Signing up...")
        service.register(with: userForm) { [weak self] result in
            self?.hideHud()
            
            switch result {
            case .success(let user):
                KeychainStorage().setUser(user)
                NotificationCenter.default.post(name: NSNotification.Name.SessionStatusChanged, object: SessionStatus.signedIn)
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    
    func hideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tapGesture)
    }
    
    func tapHandler() {
        view.endEditing(true)
    }
    
    func setupKeyboard() {
        
        keyboard.onShow { [unowned self] keyboardFrame in
            
            let keyboardMinY = keyboardFrame.minY
            let buttonMaxY = self.continueButton.frame.maxY
            let additionalPadding: CGFloat = 10.0
            
            let topOffset = max(0, buttonMaxY - keyboardMinY + additionalPadding)
            
            self.topConstraint.constant -= topOffset
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
            self.keyboard.onHide { _ in
                self.topConstraint.constant += topOffset
                    
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
