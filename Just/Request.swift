//
//  Request.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Alamofire

protocol Request {
    var baseURL: URL { get }
    var path: String { get }
    
    var method: Alamofire.HTTPMethod { get }
}

extension Request {
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var baseURL: URL {
        return URL(string: "https://still-woodland-84806.herokuapp.com/api/")!
    }
    
    var url: URL {
        return URL(string: path, relativeTo: baseURL)!
    }
}

struct RegisterRequest: Request {
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "users"
    }
}

struct CurrentUserRequest: Request {
    var path: String {
        return "sessions"
    }
}

struct LoginRequest: Request {
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "sessions"
    }
}

struct LogoutRequest: Request {
    let user: User
    
    var method: HTTPMethod {
        return .delete
    }
    
    var path: String {
        return "sessions"
    }
}

struct FetchListsRequest: Request {
    var path: String {
        return "lists"
    }
}

struct FetchListRequest: Request {
    let list: List
    
    var path: String {
        return "lists/\(list.id)"
    }
}

struct CreateListRequest: Request {
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "tasks"
    }
}

struct FetchTaskRequest: Request {
    let task: Task
    
    var path: String {
        return "tasks/\(task.id)"
    }
}

struct DeleteTaskRequest: Request {
    let task: Task
    
    var method: HTTPMethod {
        return .delete
    }
    
    var path: String {
        return "tasks/\(task.id)"
    }
}

struct CreateTaskRequest: Request {
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "tasks"
    }
}

struct UpdateTaskRequest: Request {
    let task: Task
    
    var method: HTTPMethod {
        return .put
    }
    
    var path: String {
        return "tasks/\(task.id)"
    }
}

