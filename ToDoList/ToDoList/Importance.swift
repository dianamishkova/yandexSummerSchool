//
//  Importance.swift
//  ToDoList
//
//  Created by Диана Мишкова on 28.06.24.
//

import Foundation

enum Importance: String, CaseIterable, Identifiable {
    case unimportant = "↓"
    case common = "нет"
    case important = "‼️"
    
    var id: String { self.rawValue }
}
