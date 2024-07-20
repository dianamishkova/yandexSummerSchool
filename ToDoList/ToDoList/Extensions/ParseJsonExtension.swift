//
//  ParseJsonExtension.swift
//  ToDoList
//
//  Created by Диана Мишкова on 2.07.24.
//

import Foundation
import SwiftUI

extension TodoItem {
    var json: Any {
        var jsonObject: [String: Any] = [
            "id": id,
            "text": text,
            "done": done,
            "created_at": createdAt,
            "changed_at": changedAt,
            "last_updated_by": lastUpdatedBy,
        ]
        if importance != .basic {
            jsonObject["importance"] = importance.rawValue
        }
        if let deadline {
            jsonObject["deadline"] = deadline
        }
        if let color {
            jsonObject["color"] = color
        }
        return jsonObject
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any],
              let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let done = dict["done"] as? Bool,
              let createdAt = dict["created_at"] as? Int64,
              let changedAt = dict["changed_at"] as? Int64,
              let lastUpdatedBy = dict["last_updated_by"] as? String else {
            return nil
        }
        
        // Обработка importance
        let importanceString = dict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? Importance.basic.rawValue) ?? .basic
        
        // Обработка deadline
        let deadline = dict["deadline"] as? Int64
        
        // Обработка color
        let color = dict["color"] as? String
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: done,
            createdAt: createdAt,
            changedAt: changedAt,
            color: color,
            lastUpdatedBy: lastUpdatedBy
        )
    }
}
