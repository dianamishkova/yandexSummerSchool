//
//  Importance.swift
//  ToDoList
//
//  Created by Диана Мишкова on 28.06.24.
//

import Foundation

enum Importance: String, CaseIterable, Identifiable, Codable {
    case low = "low"
    case basic = "basic"
    case important = "important"
    
    var id: String { self.rawValue }
}
