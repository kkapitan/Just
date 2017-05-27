//
//  TasksService.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import RxSwift

final class TasksService {
    
    func updateStatus(task: Task, completion: @escaping (ApiResponse<Task>) -> ()) {
        let requester = ApiRequester()
        let request = UpdateTaskRequest(task: task)
        let params = UpdateStatusParams(task: task)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
    func createTask(with form: TaskForm, completion: @escaping (ApiResponse<Task>) -> ()) {
        let requester = ApiRequester()
        let request = CreateTaskRequest()
        let params = CreateTaskParams(form: form)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
    func updateTask(task: Task, with form: TaskForm, completion: @escaping (ApiResponse<Task>) -> ()) {
        let requester = ApiRequester()
        let request = UpdateTaskRequest(task: task)
        let params = UpdateTaskParams(form: form)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
    func deleteTask(task: Task, completion: @escaping (ApiResponse<Void>) -> ()) {
        let requester = ApiRequester()
        let request = DeleteTaskRequest(task: task)
        
        requester.request(request: request, completion: completion)
    }
}

extension TasksService {
    
    func fetchTaskDetails(for task: Task) -> Observable<ApiResponse<Task>> {
        let requester = ApiRequester()
        let request = FetchTaskRequest(task: task)
        
        return requester.request(request: request)
    }
    
    func updateStatus(task: Task) -> Observable<ApiResponse<Task>> {
        let requester = ApiRequester()
        let request = UpdateTaskRequest(task: task)
        let params = UpdateStatusParams(task: task)
        
        return requester.request(request: request, params: params)
    }
    
    func createTask(with form: TaskForm) -> Observable<ApiResponse<Task>> {
        let requester = ApiRequester()
        let request = CreateTaskRequest()
        let params = CreateTaskParams(form: form)
        
        return requester.request(request: request, params: params)
    }
    
    func updateTask(task: Task, with form: TaskForm) -> Observable<ApiResponse<Task>> {
        let requester = ApiRequester()
        let request = UpdateTaskRequest(task: task)
        let params = UpdateTaskParams(form: form)
        
        return requester.request(request: request, params: params)
    }
    
    func deleteTask(task: Task) -> Observable<ApiResponse<Void>> {
        let requester = ApiRequester()
        let request = DeleteTaskRequest(task: task)
        
        return requester.request(request: request)
    }
}
