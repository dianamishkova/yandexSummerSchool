//
//  TodoItem.swift
//  ToDoList
//
//  Created by Диана Мишкова on 15.06.24.
//

import Foundation
import SwiftUI

struct TodoItem: Identifiable {
    
    
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


extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        var components = [String]()
        var current = ""
        var insideQuotes = false
        
        for char in csv {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                components.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        components.append(current)
        components = components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard components.count >= 7 else { return nil }
           
        let id = components[0]
        let text = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\"\""))
        let importance = Importance(rawValue: components[2]) ?? .common
        let deadline = components[3].isEmpty ? nil : Date(timeIntervalSince1970: TimeInterval(components[3])!)
        let completed = Bool(components[4]) ?? false
        let creationDate = Date(timeIntervalSince1970: TimeInterval(components[5])!)
        let editDate = components[6].isEmpty ? nil : Date(timeIntervalSince1970: TimeInterval(components[6])!)
        
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
