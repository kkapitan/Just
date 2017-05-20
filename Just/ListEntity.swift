//
//  ListEntity.swift
//  Just
//
//  Created by Krzysztof Kapitan on 20.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation
import RealmSwift


final class ListEntity: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    
    let tasks = RealmSwift.List<TaskEntity>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension List: Persistable {
    var primaryKey: Any? {
        return id
    }
    
    init(entity: ListEntity) {
        id = entity.id
        name = entity.name
        tasks = entity.tasks.lazy.map(Task.init(entity:))
    }
    
    func toEntity() -> ListEntity {
        let entity = ListEntity()
        
        entity.id = id
        entity.name = name
        
        let tasks = self.tasks.lazy.map { $0.toEntity() }
        entity.tasks.append(objectsIn: tasks)
        
        return entity
    }
}
