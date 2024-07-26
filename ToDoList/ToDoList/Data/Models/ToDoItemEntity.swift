//
//  ToDoItemEntity.swift
//  ToDoList
//
//  Created by Диана Мишкова on 25.07.24.
//

import Foundation
import SwiftData

@Model
final class TodoItemEntity: Identifiable {
    @Attribute(.unique) let id: String
    var text: String
    var importance: Importance
    var deadline: Int64?
    var done: Bool
    var color: String?
    let createdAt: Int64
    var changedAt: Int64
    var lastUpdatedBy: String
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .basic,
         deadline: Int64? = nil,
         done: Bool = false,
         createdAt: Int64 = Int64(Date().timeIntervalSince1970),
         changedAt: Int64 = Int64(Date().timeIntervalSince1970),
         color: String? = nil,
         lastUpdatedBy: String) {
            self.id = id
            self.text = text
            self.importance = importance
            self.deadline = deadline
            self.done = done
            self.createdAt = createdAt
            self.changedAt = changedAt
            self.color = color
            self.lastUpdatedBy = lastUpdatedBy
        }
}
