//
//  DefaultNetworkingService.swift
//  ToDoList
//
//  Created by Диана Мишкова on 17.07.24.
//

import Foundation

struct DefaultNetworkingService: NetworkingService {
    func getToDos(completion: @escaping GetToDoAPIResponse) async {
        guard let url = URL(string: "https://hive.mrdekk.ru/todo/list") else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer Varda", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let list = try JSONDecoder().decode(ToDoListResponse.self, from: data)
                completion(.success(list))
            } catch {
                completion(.failure(.parsingError))
            }
        } catch {
            completion(.failure(.networkError(error)))
        }
    }
    
    func updateToDoList(
        todoList: [TodoItem],
        revision: Int32,
        completion: @escaping UpdateTodoListAPIResponse
    ) async {
        guard let url = URL(string: "https://hive.mrdekk.ru/todo/list") else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer Varda", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let data = try JSONEncoder().encode(ToDoListRequest(status: "ok", list: todoList))
            request.httpBody = data
        } catch {
            completion(.failure(.encodingError))
        }
        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let list = try JSONDecoder().decode(ToDoListResponse.self, from: data)
                completion(.success(list))
            } catch {
                completion(.failure(.parsingError))
            }
         } catch {
            completion(.failure(.networkError(error)))
        }
    }
    
    func getToDoItem(id: String, completion: @escaping GetToDoItemAPIResponse) async {
        guard let url = URL(string: "https://hive.mrdekk.ru/todo/list/\(id)") else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer Varda", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            switch httpResponse.statusCode {
            case 200:
                do {
                    let item = try JSONDecoder().decode(ToDoItemResponse.self, from: data)
                    completion(.success(item))
                } catch {
                    completion(.failure(.parsingError))
                }
            case 404:
                completion(.failure(.itemNotFound))
            default:
                completion(.failure(.serverError))
            }
        } catch {
            completion(.failure(.networkError(error)))
        }
    }
    
    func addToDo(item: TodoItem, revision: Int32, completion: @escaping AddToDoAPIResponse) async {
        guard let url = URL(string: "https://hive.mrdekk.ru/todo/list") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer Varda", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let data = try JSONEncoder().encode(ToDoItemRequest(status: "ok", element: item))
            request.httpBody = data
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            switch httpResponse.statusCode {
            case 200:
                do {
                    let item = try JSONDecoder().decode(ToDoItemResponse.self, from: data)
                    completion(.success(item))
                } catch {
                    completion(.failure(.parsingError))
                }
            case 400:
                completion(.failure(.invalidRevision))
            default:
                completion(.failure(.serverError))
            }
        } catch {
            completion(.failure(.networkError(error)))
        }
    }
    
    func updateToDoItem(todoItem: TodoItem, revision: Int32, completion: @escaping UpdateToDoItemAPIResponse) async {
        guard let url = URL(string: "https://hive.mrdekk.ru/todo/list/\(todoItem.id)") else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer Varda", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(ToDoItemRequest(status: "ok", element: todoItem))
            request.httpBody = data
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            switch httpResponse.statusCode {
            case 200:
                do {
                    let item = try JSONDecoder().decode(ToDoItemResponse.self, from: data)
                    completion(.success(item))
                } catch {
                    completion(.failure(.parsingError))
                }
            case 400:
                completion(.failure(.invalidRevision))
            case 404:
                completion(.failure(.itemNotFound))
            default:
                completion(.failure(.serverError))
            }
        } catch {
            completion(.failure(.networkError(error)))
        }
    }
    
    func deleteItem(id: String, revision: Int32, completion: @escaping DeleteToDoItemAPIResponse) async {
        guard let url = URL(string: "https://hive.mrdekk.ru/todo/list/\(id)") else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer Varda", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch statusCode {
            case 200:
                do {
                    let item = try JSONDecoder().decode(ToDoItemResponse.self, from: data)
                    completion(.success(item.element))
                } catch {
                    completion(.failure(.parsingError))
                }
            case 404:
                completion(.failure(.itemNotFound))
            case 400:
                completion(.failure(.invalidRevision))
            default:
                completion(.failure(.serverError))
            }
        } catch {
            completion(.failure(.networkError(error)))
        }
    }
}
