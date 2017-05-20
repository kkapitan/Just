//
//  Forms.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

struct UserForm {
    var username: String?
    var email: String?
    var password: String?
    var confirmation: String?
}

struct TaskForm {
    var title: String?
    var due: Date?
    var listId: Int?
    
    var description: String?
    
    var priority: Priority?
    var isDone: Bool?
    
    init(task: Task) {
        title = task.title
        due = task.dueDate
        description = task.taskDescription
        priority = task.priority
        isDone = task.isDone
    }
    
    init() {
        title = nil
        due = nil
        description = nil
        priority = nil
        isDone = nil
    }
}

struct ListForm {
    var title: String?
}
