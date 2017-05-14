//
//  ListService.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

final class ListService {
    
    func fetchTasks(for list: List, completion: @escaping (ApiResponse<List>) -> ()) {
        let requester = ApiRequester()
        let request = FetchListRequest(list: list)
    
        requester.request(request: request, completion: completion)
    }
    
    func fetchLists(completion: @escaping (ApiResponse<[List]>) -> ()) {
        let requester = ApiRequester()
        let request = RegisterRequest()
        
        requester.request(request: request, completion: completion)
    }
    
    func createList(with form: ListForm, completion: @escaping (ApiResponse<List>) -> ()) {
        let requester = ApiRequester()
        let request = CreateListRequest()
        let params = CreateListParams(form: form)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
}
