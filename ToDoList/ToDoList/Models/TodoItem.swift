//
//  TodoItem.swift
//  ToDoList
//
//  Created by Диана Мишкова on 15.06.24.
//
import FileCachePackage
import Foundation
import SwiftUI

struct TodoItem: Identifiable, CSVProtocol, JSONProtocol {
    let id: String
    var text: String
    var importance: Importance
    var deadline: Date?
    var completed: Bool
    let creationDate: Date
    let editDate: Date?
    var colorHex: Color?
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .common,
         deadline: Date? = nil,
         completed: Bool = false,
         creationDate: Date = Date(),
         editDate: Date? = nil,
         colorHex: Color? = nil) {
            self.id = id
            self.text = text
            self.importance = importance
            self.deadline = deadline
            self.completed = completed
            self.creationDate = creationDate
            self.editDate = editDate
            self.colorHex = colorHex
        }
}
