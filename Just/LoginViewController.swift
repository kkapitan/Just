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
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    fileprivate let keyboard = Keyboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editingChanged(nil)
        
        setupKeyboard()
        hideKeyboardOnTap()
    }
    
    @IBAction func editingChanged(_ sender: UITextField?) {
        let valid = isFormValid()
        
        continueButton.isEnabled = valid
        continueButton.backgroundColor = valid ? .buttonGreen : .buttonGray
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        let usernameOrEmail = usernameOrEmailTextField.text!
        let password = passwordTextField.text!
        
        let credentials = Credentials(usernameOrEmail: usernameOrEmail, password: password)
        let service = UserService()
        
        showHud()
        service.login(with: credentials) { [weak self] result in
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
    
    func isFormValid() -> Bool {
        let usernameOrEmail = usernameOrEmailTextField.text!
        let password = passwordTextField.text!
        
        return (Validations.isValid(email: usernameOrEmail)
            || Validations.isValid(username: usernameOrEmail))
            && Validations.isValid(password: password)
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
