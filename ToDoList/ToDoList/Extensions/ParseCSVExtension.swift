//  ParseCSVExtension.swift
//  ToDoList
//
//  Created by Диана Мишкова on 2.07.24.
//

import Foundation

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
        let importance = Importance(rawValue: components[2]) ?? .basic
        let deadline = components[3].isEmpty ? nil : Int64(components[3]) ?? 0
        let completed = Bool(components[4]) ?? false
        let creationDate = Int64(components[5]) ?? 0
        let editDate = Int64(components[6]) ?? 0
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            done: completed,
            createdAt: creationDate,
            changedAt: editDate, lastUpdatedBy: ""
        )
    }
}
