//
//  UserService.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

final class UserService {
    
    func login(with credentials: Credentials, completion: @escaping (ApiResponse<User>) -> ()) {
        let requester = ApiRequester()
        let request = LoginRequest()
        let params = LoginParams(credentials: credentials)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
    func register(with form: UserForm, completion: @escaping (ApiResponse<User>) -> ()) {
        let requester = ApiRequester()
        let request = RegisterRequest()
        let params = RegisterParams(form: form)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
    func logout(completion: @escaping (ApiResponse<Void>) -> ()) {
        let requester = ApiRequester()
        let request = LogoutRequest()
        
        requester.request(request: request, completion: completion)
    }
    
    func getCurrentUser(completion: @escaping (ApiResponse<User>) -> ()) {
        let requester = ApiRequester()
        let request = CurrentUserRequest()
        
        requester.request(request: request, completion: completion)
    }
}
