//
//  TodoItem.swift
//  ToDoList
//
//  Created by Диана Мишкова on 15.06.24.
//
import FileCachePackage
import Foundation
import SwiftUI

struct TodoItem: Codable, Identifiable, CSVProtocol, JSONProtocol {
    let id: String
    var text: String
    var importance: Importance
    var deadline: Int64?
    var done: Bool
    var color: String?
    let createdAt: Int64
    var changedAt: Int64
    let lastUpdatedBy: String
    
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}
