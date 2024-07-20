//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Диана Мишкова on 17.07.24.
//

import Foundation

typealias GetToDoAPIResponse = (Swift.Result<ToDoListResponse, DataError>) -> Void
typealias UpdateTodoListAPIResponse = (Swift.Result<ToDoListResponse, DataError>) -> Void
typealias GetToDoItemAPIResponse = (Swift.Result<ToDoItemResponse, DataError>) -> Void
typealias AddToDoAPIResponse = (Swift.Result<ToDoItemResponse, DataError>) -> Void
typealias UpdateToDoItemAPIResponse = (Swift.Result<ToDoItemResponse, DataError>) -> Void
typealias DeleteToDoItemAPIResponse = (Swift.Result<TodoItem, DataError>) -> Void

protocol NetworkingService {
    func getToDos(completion: @escaping (GetToDoAPIResponse)) async
    func addToDo(item: TodoItem, revision: Int32, completion: @escaping AddToDoAPIResponse) async
    func updateToDoList(todoList: [TodoItem], revision: Int32, completion: @escaping UpdateTodoListAPIResponse) async
    func getToDoItem(id: String, completion: @escaping GetToDoItemAPIResponse) async
    func updateToDoItem(todoItem: TodoItem, revision: Int32, completion: @escaping UpdateToDoItemAPIResponse) async
    func deleteItem(id: String, revision: Int32, completion: @escaping DeleteToDoItemAPIResponse) async
}
