//
//  List.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import JSONCodable

struct List {
    let id: String
    let name: String
    
    let tasks: [Task]
}

extension List: JSONCodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        
        id = try decoder.decode("id")
        name = try decoder.decode("title")
        tasks = try decoder.decode("tasks") ?? []
    }
}
