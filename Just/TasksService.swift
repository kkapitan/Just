//
//  TasksService.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

final class TasksService {
    
    func fetchTaskDetails(for task: Task, completion: @escaping (ApiResponse<Task>) -> ()) {
        let requester = ApiRequester()
        let request = FetchTaskRequest(task: task)
        
        requester.request(request: request, completion: completion)
    }
    
    func createTask(with form: TaskForm, completion: @escaping (ApiResponse<Task>) -> ()) {
        let requester = ApiRequester()
        let request = CreateTaskRequest()
        let params = CreateTaskParams(form: form)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
    func updateTask(task: Task, with form: TaskForm, completion: @escaping (ApiResponse<List>) -> ()) {
        let requester = ApiRequester()
        let request = UpdateTaskRequest(task: task)
        let params = UpdateTaskParams(form: form)
        
        requester.request(request: request, params: params, completion: completion)
    }
    
    func deleteTask(task: Task, completion: @escaping (ApiResponse<Bool>) -> ()) {
        let requester = ApiRequester()
        let request = DeleteTaskRequest(task: task)
        
        requester.request(request: request, completion: completion)
    }
}
