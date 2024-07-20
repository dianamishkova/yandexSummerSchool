//
//  DataError.swift
//  ToDoList
//
//  Created by Диана Мишкова on 4.07.24.
//

import Foundation

enum DataError: Error {
    case itemNotFound
    case invalidRevision
    case retrievingError(String)
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case encodingError
    case parsingError
    case serverError
}
