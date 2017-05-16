//
//  RequestParams.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

protocol RequestParams {
    var params: [String: Any] { get }
}

struct RegisterParams: RequestParams {
    let form: UserForm
    
    var params: [String: Any] {
        return [
            "user" : [
                "username" : form.username ?? "",
                "email" : form.email ?? "",
                "password" : form.password ?? "",
                "password_confirmation" : form.confirmation ?? ""
            ]
        ]
    }
}

struct LoginParams: RequestParams {
    let credentials: Credentials
    
    var params: [String: Any] {
        return [
            "email" : credentials.usernameOrEmail,
            "password" : credentials.password,
        ]
    }
}

struct CreateListParams: RequestParams {
    let form: ListForm
    
    var params: [String: Any] {
        return [
            "title": form.title ?? ""
        ]
    }
}

struct CreateTaskParams: RequestParams {
    let form: TaskForm
    
    var params: [String: Any] {
        return [
            "title" : form.title ?? "",
            "description" : form.description ?? "",
            "priority" : (form.priority ?? .medium).rawValue,
            "list_id" : form.listId ?? "",
        ]
    }
}

struct UpdateStatusParams: RequestParams {
    let task: Task
    
    var params: [String: Any] {
        return ["done": !task.isDone]
    }
}

struct UpdateTaskParams: RequestParams {
    let form: TaskForm
    
    var params: [String: Any] {
        return [
            "title" : form.title ?? "",
            "description" : form.description ?? "",
            "priority" : (form.priority ?? .medium).rawValue,
            "done" : form.isDone ?? false,
            "list_id" : form.listId ?? "",
        ]
    }
}
