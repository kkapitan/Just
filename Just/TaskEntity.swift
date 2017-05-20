//
//  TaskEntity.swift
//  Just
//
//  Created by Krzysztof Kapitan on 20.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation
import RealmSwift


final class TaskEntity: Object {
    
    dynamic var id: Int = 0
    dynamic var listId: Int = 0
    dynamic var title: String = ""
    dynamic var dueDate: Date?
    dynamic var priority: String = Priority.medium.rawValue
    dynamic var taskDescription: String?
    dynamic var isDone: Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension Task: Persistable {
    var primaryKey: Any? {
        return id
    }
    
    init(entity: TaskEntity) {
        id = entity.id
        listId = entity.id
        title = entity.title
        dueDate = entity.dueDate
        priority = Priority(rawValue: entity.priority) ?? .medium
        taskDescription = entity.taskDescription
        isDone = entity.isDone
    }
    
    func toEntity() -> TaskEntity {
        let entity = TaskEntity()
        
        entity.id = id
        entity.title = title
        entity.dueDate = dueDate
        entity.priority = priority.rawValue
        entity.taskDescription = taskDescription
        entity.isDone = isDone
        entity.listId = listId
        
        return entity
    }
    
}



