//
//  LoginViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxOptional

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameOrEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    fileprivate let keyboard = Keyboard()
    
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        hideKeyboardOnTap()
        
        setupBindings()
    }
    
    func setupBindings() {
        
        usernameOrEmailTextField.rx
            .text
            .asObservable()
            .bindTo(viewModel.email)
            .addDisposableTo(disposeBag)
        
        passwordTextField.rx
            .text
            .asObservable()
            .bindTo(viewModel.password)
            .addDisposableTo(disposeBag)
        
        viewModel
            .isValid
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] valid in
                self.continueButton.isEnabled = valid
                self.continueButton.backgroundColor = valid ? .buttonGreen : .buttonGray
            })
            .addDisposableTo(disposeBag)
        
        continueButton.rx
            .tap
            .asObservable()
            .flatMapLatest { [unowned self] (Void) -> Observable<LoginViewModel.LoginResult> in
                self.showProgress("Signing in...")
                
                return self.viewModel.login()
            }.subscribe(onNext: { [unowned self] result in
                self.hideHud()
                
                if case .failure(let error) = result {
                    self.showError(error)
                }
            }).addDisposableTo(disposeBag)
    }
    
    func hideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer()
        
        tapGesture.rx.event.subscribe(onNext: { [unowned self] _ in
            self.view.endEditing(true)
        }).addDisposableTo(disposeBag)
        
        view.addGestureRecognizer(tapGesture)
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
