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
    let listId: Int
    
    let title: String
    let dueDate: Date?
    
    let priority: Priority
    let taskDescription: String?
    
    let isDone: Bool
}

extension Task: Equatable {
    public static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Task: JSONCodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        
        id = try decoder.decode("id")
        title = try decoder.decode("title")
        
        taskDescription = try decoder.decode("description")
        isDone = try decoder.decode("done")
        
        dueDate = try decoder.decode("deadline", transformer: dateTransformer)
        
        let priorityString: String? = try decoder.decode("priority")
        priority = priorityString.flatMap({ Priority(rawValue: $0) }) ?? .medium
        
        listId = try decoder.decode("list_id")
    }
}

let dateTransformer = JSONTransformer<TimeInterval, Date>(decoding: { value in
    return Date(timeIntervalSince1970: value)
}) { date -> TimeInterval? in
    return date.timeIntervalSince1970
}
