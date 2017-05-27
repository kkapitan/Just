//
//  RegistrationViewModel.swift
//  Just
//
//  Created by Krzysztof Kapitan on 27.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

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
