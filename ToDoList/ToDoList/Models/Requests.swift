//
//  Requests.swift
//  ToDoList
//
//  Created by Диана Мишкова on 19.07.24.
//

import Foundation

struct ToDoListRequest: Codable {
    let status: String
    var list: [TodoItem]
}

struct ToDoItemRequest: Codable {
    let status: String
    var element: TodoItem
}
