//
//  ListService.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation
import RxSwift

final class ListService {
    
    func fetchTasks(for list: List) -> Observable<ApiResponse<List>> {
        let requester = ApiRequester()
        let request = FetchListRequest(list: list)
    
        return requester.request(request: request)
    }
    
    func fetchLists()  -> Observable<ApiResponse<[List]>> {
        let requester = ApiRequester()
        let request = FetchListsRequest()
        
        return requester.request(request: request)
    }
    
    func createList(with form: ListForm) -> Observable<ApiResponse<List>> {
        let requester = ApiRequester()
        let request = CreateListRequest()
        let params = CreateListParams(form: form)
        
        return requester.request(request: request, params: params)
    }
    
}
