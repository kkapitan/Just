//
//  TasksStorage.swift
//  Just
//
//  Created by Krzysztof Kapitan on 20.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

final class TasksStorage: Storage {
    typealias T = Task
    
    let realm: Realm
    
    init() throws {
        self.realm = try Realm()
    }
    
    func tasks(for list: List, done: Bool) -> Observable<[Task]> {
        let predicate = NSPredicate(format: "isDone == %@ AND listId == %@", NSNumber(value: done), NSNumber(value: list.id))
        
        let items = get()
            .filter(predicate)
            .sorted(byKeyPath: "id", ascending: false)
        
        return Observable.collection(from: items).map {
            return $0.map(Task.init(entity:))
        }
    }
}
