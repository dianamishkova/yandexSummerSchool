//
//  ParseJsonExtension.swift
//  ToDoList
//
//  Created by Диана Мишкова on 2.07.24.
//

import Foundation

extension TodoItem {
    var json: Any {
        var jsonObject: [String: Any] = [
            "id": id,
            "text": text,
            "completed": completed,
            "creationDate": creationDate.timeIntervalSince1970
        ]
        if importance != .common {
            jsonObject["importance"] = importance.rawValue
        }
        if let deadline = deadline {
            jsonObject["deadline"] = deadline.timeIntervalSince1970
        }
        if let editDate = editDate {
            jsonObject["editDate"] = editDate.timeIntervalSince1970
        }
        
        return jsonObject
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any],
            let id = dict["id"] as? String,
            let text = dict["text"] as? String,
            let completed = dict["completed"] as? Bool,
            let creationTimestamp = dict["creationDate"] as? TimeInterval else {
                return nil
            }
        let creationDate = Date(timeIntervalSince1970: creationTimestamp)
            
        let editTimestamp = dict["editDate"] as? TimeInterval
        let editDate = editTimestamp != nil ? Date(timeIntervalSince1970: editTimestamp!) : nil
        
        let importanceString = dict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? Importance.common.rawValue) ?? .common
        
        let deadlineTimestamp = dict["deadline"] as? TimeInterval
        let deadline = deadlineTimestamp != nil ? Date(timeIntervalSince1970: deadlineTimestamp!) : nil
            
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            completed: completed,
            creationDate: creationDate,
            editDate: editDate
        )
    }
}
