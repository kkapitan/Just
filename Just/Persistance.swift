//
//  Persistance.swift
//  Just
//
//  Created by Krzysztof Kapitan on 16.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import RealmSwift

protocol Persistable {
    associatedtype Entity: Object
    var primaryKey: Any? { get }
    
    init(entity: Entity)
    func toEntity() -> Entity
}

final class TaskEntity: Object {
    
    dynamic var id: Int = 0
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
        
        return entity
    }
    
}

protocol Storage {
    associatedtype T: Persistable
    
    var realm: Realm { get }
    
    func add(_ value: T, update: Bool) throws
    
    func add(_ values: [T], update: Bool) throws
    
    func remove(_ value: T) throws
    
    func get() -> Results<T.Entity>
}

extension Storage {
    
    func add(_ value: T, update: Bool = false) throws {
        try realm.write {
            realm.add(value.toEntity(), update: update)
        }
    }
    
    func add(_ values: [T], update: Bool = false) throws {
        try realm.write {
            realm.add(values.map { $0.toEntity() }, update: update)
        }
    }
    
    func remove(_ value: T) throws {
        guard let object = realm.object(ofType: T.Entity.self, forPrimaryKey: value.primaryKey) else { return }
        
        try realm.write {
            realm.delete(object)
        }
    }
    
    func get() -> Results<T.Entity> {
        return realm.objects(T.Entity.self)
    }
}

final class TasksStorage: Storage {
    typealias T = Task
    
    let realm: Realm
    
    init() throws {
        self.realm = try Realm()
    }
    
    func tasks() -> [Task] {
        return get().map(Task.init(entity:))
    }
    
    func tasks(_ done: Bool) -> [Task] {
        let predicate = NSPredicate(format: "isDone == %@", NSNumber(value: done))
        
        return get().filter(predicate).map(Task.init(entity:))
    }
}

final class ListStorage: Storage {
    typealias T = List
    
    let realm: Realm
    
    init() throws {
        self.realm = try Realm()
    }
    
    func lists() -> [List] {
        return get().map(List.init(entity:))
    }
}

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
