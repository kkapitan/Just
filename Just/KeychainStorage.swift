//
//  KeychainStorage.swift
//  Just
//
//  Created by Krzysztof Kapitan on 14.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import KeychainAccess
import JSONCodable

struct KeychainStorage {
    fileprivate let internalKeychain: Keychain
    
    init(service: String = "com.cappsoft.just.keychain") {
        self.internalKeychain = Keychain(service: service)
    }
    
    func put<T: JSONEncodable>(_ value: T, forKey: String) {
        guard let data = (try? value.toJSON() as? [String: Any])?
            .flatMap({NSKeyedArchiver.archivedData(withRootObject: $0)})
        else {
            fatalError("Cannot archive json")
        }
        
        try? internalKeychain.set(data, key: forKey)
    }
    
    func get<T: JSONDecodable>(key: String) -> T? {
        return (try? internalKeychain.getData(key))?
            .flatMap({ NSKeyedUnarchiver.unarchiveObject(with: $0) as? [String: Any]})
            .flatMap({ try? T(object: $0) })
    }
    
    func delete(key: String) {
        try? internalKeychain.remove(key)
    }
}

extension KeychainStorage {
    
    func getUser() -> User? {
        return get(key: userKey)
    }
    
    func setUser(_ user: User) {
        put(user, forKey: userKey)
    }
    
    var userKey: String {
        return "com.cappsoft.just.keychain.user.key"
    }
}
