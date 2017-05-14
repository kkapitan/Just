//
//  User.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import JSONCodable

struct User {
    let id: Int
    
    let username: String
    let email: String
    
    let token: String
}

extension User: JSONCodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        
        id = try decoder.decode("id")
        
        username = try decoder.decode("name")
        email = try decoder.decode("email")
        
        token = try decoder.decode("token")
    }
    
    func toJSON() throws -> Any {
        return try JSONEncoder.create { (encoder) in
            try encoder.encode(id, key: "id")
            try encoder.encode(username, key: "name")
            try encoder.encode(email, key: "email")
            try encoder.encode(token, key: "token")
        }
    }
}
