//
//  Responses.swift
//  ToDoList
//
//  Created by Диана Мишкова on 19.07.24.
//

import Foundation

struct ToDoListResponse: Codable {
    let status: String
    var list: [TodoItem]
    let revision: Int32
}

struct ToDoItemResponse: Codable {
    let status: String
    var element: TodoItem
    var revision: Int32
}
