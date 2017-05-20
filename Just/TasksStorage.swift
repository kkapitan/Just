//
//  TasksStorage.swift
//  Just
//
//  Created by Krzysztof Kapitan on 20.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation
import RealmSwift

final class TasksStorage: Storage {
    typealias T = Task
    
    let realm: Realm
    
    init() throws {
        self.realm = try Realm()
    }
    
    func tasks(for list: List, done: Bool) -> [Task] {
        let predicate = NSPredicate(format: "isDone == %@ AND listId == %@", NSNumber(value: done), NSNumber(value: list.id))
        
        return get().filter(predicate).map(Task.init(entity:))
    }
}
