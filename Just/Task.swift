//
//  Task.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import JSONCodable

struct Task {
    let id: Int
    
    let title: String
    let dueDate: Date?
    
    let priority: Priority
    let taskDescription: String?
    
    let isDone: Bool
}


extension Task: JSONCodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        
        id = try decoder.decode("id")
        title = try decoder.decode("title")
        
        taskDescription = try decoder.decode("description")
        isDone = try decoder.decode("done")
        
        //dueDate = try decoder.decode("date")
        dueDate = nil
        
        let priorityString: String? = try decoder.decode("priority")
        priority = priorityString.flatMap({ Priority(rawValue: $0) }) ?? .medium
    }
}
