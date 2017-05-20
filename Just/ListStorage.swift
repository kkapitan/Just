//
//  ListStorage.swift
//  Just
//
//  Created by Krzysztof Kapitan on 20.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation
import RealmSwift


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
