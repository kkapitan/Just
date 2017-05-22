//
//  RegistrationViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit


import RxSwift
import RxCocoa
import RxOptional

final class RegistrationViewModel {
    
    enum RegisterResult {
        case success
        case failure(Error?)
    }
    
    // Input
    let username: Variable<String?> = Variable(nil)
    let email: Variable<String?> = Variable(nil)
    let password: Variable<String?> = Variable(nil)
    let confirmation: Variable<String?> = Variable(nil)
    
    // Output
    let isValid: Observable<Bool>
    
    init() {
        
        let isUsernameValid = username
            .asObservable()
            .filterNil()
            .map(Validations.isValid(username:))
        
        let isEmailValid = email
            .asObservable()
            .filterNil()
            .map(Validations.isValid(email:))
        
        let passwordObservable = password
            .asObservable()
            .filterNil()
            .shareReplay(1)
        
        let confirmationObservable = confirmation
            .asObservable()
            .filterNil()
        
        let isPasswordValid = passwordObservable
            .map(Validations.isValid(password:))
        
        let isConfirmationValid = Observable
            .combineLatest(passwordObservable, confirmationObservable) {
                Validations.isValid(confirmation: $0, of: $1)
            }
        
        isValid = Observable
            .combineLatest([isUsernameValid, isEmailValid, isPasswordValid, isConfirmationValid]) {
                $0.reduce(true) { $1 && $0 }
            }.startWith(false)
    }
    
    func register() -> Observable<RegisterResult> {
        let service = UserService()
        
        let form = UserForm(username: username.value,
                            email: email.value,
                            password: password.value,
                            confirmation: confirmation.value)
        
        return service.register(with: form).flatMap { response -> Observable<RegisterResult> in
            switch response {
            case .failure(let error):
                return Observable.just(.failure(error))
            case .success(let user):
                
                KeychainStorage().setUser(user)
                NotificationCenter.default.post(name: NSNotification.Name.SessionStatusChanged, object: SessionStatus.signedIn)
                
                return Observable.just(.success)
            }
        }
    }
}


final class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmationTextField: UITextField!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var continueButton: UIButton!
    
    fileprivate let keyboard = Keyboard()
    
    let disposeBag = DisposeBag()
    let viewModel = RegistrationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        hideKeyboardOnTap()
        
        setupBindings()
    }
    
    func setupBindings() {
        
        usernameTextField.rx
            .text
            .asObservable()
            .bindTo(viewModel.username)
            .addDisposableTo(disposeBag)
        
        emailTextField.rx
            .text
            .asObservable()
            .bindTo(viewModel.email)
            .addDisposableTo(disposeBag)
        
        confirmationTextField.rx
            .text
            .asObservable()
            .bindTo(viewModel.confirmation)
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
            .flatMapLatest { [unowned self] (Void) -> Observable<RegistrationViewModel.RegisterResult> in
                self.showProgress("Signing up...")
                
                return self.viewModel.register()
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
