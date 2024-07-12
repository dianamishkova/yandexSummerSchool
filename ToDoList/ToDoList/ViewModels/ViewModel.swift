//
//  ViewModel.swift
//  ToDoList
//
//  Created by Диана Мишкова on 12.07.24.
//
import CocoaLumberjackSwift
import FileCachePackage
import Foundation

class ViewModel: ObservableObject {
    @Published private(set) var todoItemsList: [TodoItem] = []
    @Published private(set) var datesList: [String]?
    @Published private(set) var error: DataError?
    @Published private var todoDictionary = [String: DateSection]()
    private(set) var dateSectionsList: [DateSection]?
    let fileCache = FileCachePackage<TodoItem>()
    var completedCount: Int {
        todoItemsList.filter { $0.completed }.count
    }
    var groupedTodoItems: [Date: [TodoItem]] {
        Dictionary(grouping: todoItemsList) { item in
            Calendar.current.startOfDay(for: item.deadline ?? Date())
        }
    }
    
    func load() {
        do {
            todoItemsList = try fileCache.load(fromJSON: "todoItems.json")
        } catch {
            todoItemsList = []
        }
        prepareDateSections()
        DDLogInfo("Loaded from file")
    }
    
    func save() {
        try? fileCache.save(items: todoItemsList, to: "todoItems.json")
        DDLogInfo("Saved to file")
    }
    func addItem(_ item: TodoItem) {
        if let index = todoItemsList.firstIndex(where: { $0.id == item.id }) {
            todoItemsList[index] = item
            DDLogInfo("updated item \(item)")
        } else {
            todoItemsList.append(item)
            DDLogInfo("added item \(item)")
        }
    }
    
    func deleteItem(id: String) {
        todoItemsList.removeAll { $0.id == id }
        DDLogInfo("deleted item with id \(id)")
        save()
    }
    
    func toggleCompleted(for itemId: String) {
        if let index = todoItemsList.firstIndex(where: { $0.id == itemId }) {
            todoItemsList[index].completed.toggle()
        }
        save()
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
            if let formattedDeadline = ViewModel.formatDate(date: todo.deadline, dateFormat: "d MMMM") {
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
            try? fileCache.save(items: todoItemsList, to: "todoItems.json")
        }
    }
}
