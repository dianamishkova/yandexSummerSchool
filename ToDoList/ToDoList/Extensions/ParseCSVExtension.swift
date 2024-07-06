//
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
