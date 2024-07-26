//
//  FileCache.swift
//  ToDoList
//
//  Created by Диана Мишкова on 25.07.24.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class FileCache {
    let modelContainer: ModelContainer
    
    init() {
        let fullSchema = Schema([TodoItemEntity.self])
        self.modelContainer = try! ModelContainer(for: fullSchema)
    }
    func insert(_ todoItem: TodoItemEntity) {
        modelContainer.mainContext.insert(todoItem)
    }
    
    func fetch() -> [TodoItemEntity] {
        let fetchDescriptor = FetchDescriptor<TodoItemEntity>()
        let results = try? modelContainer.mainContext.fetch(fetchDescriptor)
        return results ?? []
    }
    
    func delete(_ todoItem: TodoItemEntity) {
            modelContainer.mainContext.delete(todoItem)
        }
        
    func update(_ todoItem: TodoItemEntity) {
        if let existingItem = try? modelContainer.mainContext.fetch(FetchDescriptor<TodoItemEntity>(predicate: #Predicate { $0.id == todoItem.id })).first {
            existingItem.text = todoItem.text
            existingItem.importance = todoItem.importance
            existingItem.deadline = todoItem.deadline
            existingItem.done = todoItem.done
            existingItem.color = todoItem.color
            existingItem.changedAt = todoItem.changedAt
            existingItem.lastUpdatedBy = todoItem.lastUpdatedBy
            try? modelContainer.mainContext.save()
        }
    }
}
