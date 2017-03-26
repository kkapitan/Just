//
//  Task.swift
//  Just
//
//  Created by Krzysztof Kapitan on 26.03.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

struct Task {
    let id: String
    
    let title: String
    let dueDate: Date
    
    let priority: Priority
    let taskDescription: String?
}
