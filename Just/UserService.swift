//
//  UserService.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import RxSwift

final class UserService {
    
    func login(with credentials: Credentials) -> Observable<ApiResponse<User>> {
        let requester = ApiRequester()
        let request = LoginRequest()
        let params = LoginParams(credentials: credentials)
        
        return requester.request(request: request, params: params)
    }
    
    func register(with form: UserForm) -> Observable<ApiResponse<User>> {
        let requester = ApiRequester()
        let request = RegisterRequest()
        let params = RegisterParams(form: form)
        
        return requester.request(request: request, params: params)
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
