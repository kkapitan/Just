//
//  Persistance.swift
//  Just
//
//  Created by Krzysztof Kapitan on 16.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import RealmSwift
import Foundation

protocol Persistable {
    associatedtype Entity: Object
    var primaryKey: Any? { get }
    
    init(entity: Entity)
    func toEntity() -> Entity
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
    
    func removeAll() throws {
        try realm.write {
            realm.delete(get())
        }
    }
    
    func get() -> Results<T.Entity> {
        return realm.objects(T.Entity.self)
    }
}
