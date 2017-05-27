//
//  LoginViewModel.swift
//  Just
//
//  Created by Krzysztof Kapitan on 27.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

final class LoginViewModel {
    
    enum LoginResult {
        case success
        case failure(Error?)
    }
    
    // Input
    let email: Variable<String?> = Variable(nil)
    let password: Variable<String?> = Variable(nil)
    
    // Output
    let isValid: Observable<Bool>
    
    init() {
        let isEmailValid = email
            .asObservable()
            .filterNil()
            .map(Validations.isValid(email:))
        
        let isPasswordValid = email
            .asObservable()
            .filterNil()
            .map(Validations.isValid(password:))
        
        isValid = Observable
            .combineLatest([isEmailValid, isPasswordValid]) {
                $0.reduce(true) { $1 && $0 }
            }.startWith(false)
    }
    
    func login() -> Observable<LoginResult> {
        guard let email = email.value, let password = password.value else {
            return Observable.just(.failure(nil))
        }
        
        let service = UserService()
        let credentials = Credentials(usernameOrEmail: email, password: password)
        
        return service.login(with: credentials).flatMap { response -> Observable<LoginResult> in
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
