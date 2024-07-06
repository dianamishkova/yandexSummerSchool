//
//  FileCache.swift
//  ToDoList
//
//  Created by Диана Мишкова on 18.06.24.
//

import Foundation

class FileCache: ObservableObject {
    @Published private(set) var todoItemsList: [TodoItem] = []
    @Published private(set) var datesList: [String]?
    @Published private(set) var error: DataError? = nil
    @Published private var todoDictionary = [String: DateSection]()
    private(set) var dateSectionsList: [DateSection]?
    
    var completedCount: Int {
        todoItemsList.filter { $0.completed }.count
    }
    
    
    var groupedTodoItems: [Date: [TodoItem]] {
        Dictionary(grouping: todoItemsList) { item in
            Calendar.current.startOfDay(for: item.deadline ?? Date())
        }
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
        try? save(to: "todoItems.json")
    }
    
    func save(to fileName: String) throws {
        let jsonObject = todoItemsList.map { $0.json }
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let url = getFileURL(fileName: fileName)
        try jsonData.write(to: url)
        prepareDateSections()
        
    }
    
    func load(fromJSON fileName: String) throws {
        let url = getFileURL(fileName: fileName)
        let jsonData = try Data(contentsOf: url)
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any] else { return }
        todoItemsList = jsonObject.compactMap { TodoItem.parse(json: $0) }
        prepareDateSections()
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
        try? save(to: "todoItems.json")
    }
    
    
    static func formatDate(date: Date?, dateFormat: String) -> String? {
        guard let date  else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    static func dateFromString(dateString: String, dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: dateString)
    }
    
    private func getFileURL(fileName: String) -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(fileName)
    }
    
    
    func prepareDateSections() {
        var todoDictionary = [String: DateSection]()
        var listOfSections = [DateSection]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let dateFormatterForDatesList = DateFormatter()
        dateFormatterForDatesList.dateFormat = "d\n \nMMMM"
        dateFormatterForDatesList.locale = Locale(identifier: "ru_RU")
        
        for todo in todoItemsList {
            if let formattedDeadline = FileCache.formatDate(date: todo.deadline, dateFormat: "d MMMM") {
                if todoDictionary[formattedDeadline] != nil {
                    todoDictionary[formattedDeadline]?.todos.append(todo)
                } else {
                    var newSection = DateSection(date: formattedDeadline, todos: [])
                    newSection.todos.append(todo)
                    todoDictionary[formattedDeadline] = newSection
                }
            } else {
                if todoDictionary["Другое"] != nil {
                    todoDictionary["Другое"]?.todos.append(todo)
                } else {
                    var newSection = DateSection(date: "Другое", todos: [])
                    newSection.todos.append(todo)
                    todoDictionary["Другое"] = newSection
                }
            }
        }

        listOfSections = Array(todoDictionary.values)
        
        listOfSections.sort {
            if $0.date == "Другое" {
                return false
            }
            if $1.date == "Другое" {
                return true
            }
            guard let date1 = dateFormatter.date(from: $0.date), let date2 = dateFormatter.date(from: $1.date) else {
                return $0.date < $1.date
            }
            return date1 < date2
        }
        
        datesList = listOfSections.map { dateSection in
            if dateSection.date == "Другое" {
                return "Другое"
            }
            return dateFormatterForDatesList.string(from: dateFormatter.date(from: dateSection.date)!)
        }
        
        dateSectionsList = listOfSections
    }


    
    func updateToDoItem(_ updatedItem: TodoItem) {
        if let index = todoItemsList.firstIndex(where: { $0.id == updatedItem.id }) {
            todoItemsList[index] = updatedItem
            try? save(to: "todoItems.json")
        }
    }
}
