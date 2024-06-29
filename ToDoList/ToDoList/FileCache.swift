//
//  FileCache.swift
//  ToDoList
//
//  Created by Диана Мишкова on 18.06.24.
//

import Foundation

class FileCache: ObservableObject {
    @Published private(set) var todoItemsList: [TodoItem] = []
    
    var completedCount: Int {
        todoItemsList.filter { $0.completed }.count
    }
    
    func addItem(_ item: TodoItem) {
        if let index = todoItemsList.firstIndex(where: { $0.id == item.id }) {
            todoItemsList[index] = item
        } else {
            todoItemsList.append(item)
        }
        
    }

    
    func deleteItem(id: String) {
        todoItemsList.removeAll { $0.id == id }
    }
    
    func save(to fileName: String) throws {
        let jsonObject = todoItemsList.map { $0.json }
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let url = getFileURL(fileName: fileName)
        try jsonData.write(to: url)
    }
    
    func load(fromJSON fileName: String) throws {
        let url = getFileURL(fileName: fileName)
        let jsonData = try Data(contentsOf: url)
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any] else { return }
        todoItemsList = jsonObject.compactMap { TodoItem.parse(json: $0) }
    }
    
    func load(fromCSV fileName: String) throws {
        let url = getFileURL(fileName: fileName)
        let csvString = try String(contentsOf: url)
        let rows = csvString.components(separatedBy: "\n").dropFirst()
        todoItemsList = rows.compactMap { TodoItem.parse(csv: $0) }
    }
    
    func toggleCompleted(for itemId: String) {
        if let index = todoItemsList.firstIndex(where: { $0.id == itemId }) {
            todoItemsList[index].completed.toggle()
        }
    }
    func formatDate(date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    private func getFileURL(fileName: String) -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(fileName)
    }

}
