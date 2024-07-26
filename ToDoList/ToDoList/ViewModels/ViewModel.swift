//
//  ViewModel.swift
//  ToDoList
//
//  Created by Диана Мишкова on 12.07.24.
//
import CocoaLumberjackSwift
import Combine
import FileCachePackage
import Foundation
import Network

@MainActor
class ViewModel: ObservableObject {
    @Published private(set) var todoItemsList: [TodoItem] = []
    @Published var todoItem = TodoItem(text: "", lastUpdatedBy: "")
    @Published var revision: Int32 = 0
    @Published private(set) var datesList: [String]?
    @Published private(set) var error: DataError?
    @Published private var todoDictionary = [String: DateSection]()
    private(set) var dateSectionsList: [DateSection]?
    private var networkConnectivity = NWPathMonitor()
    private var deletedItem: TodoItem?
    private var isDirty = false
    var update = false
    let fileCache = FileCachePackage<TodoItem>()
    let apiService: NetworkingService
    
    private var timer: AnyCancellable?
    
    init(apiService: NetworkingService = DefaultNetworkingService()) {
        self.apiService = apiService
        networkConnectivity.start(queue: DispatchQueue.global(qos: .background))
    }
    
    var completedCount: Int {
        todoItemsList.filter { $0.done }.count
    }
    var groupedTodoItems: [Date: [TodoItem]] {
        Dictionary(grouping: todoItemsList) { item in
            Calendar.current.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(item.deadline ?? 0)))
        }
    }
    func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.getToDos()
                }
            }
    }
    func stopTimer() {
        timer?.cancel()
    }

    func getToDos() async {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            if isDirty {
                await updateToDoList(toDoList: todoItemsList, revision: revision)
            }
            await apiService.getToDos { [weak self] result in
                switch result {
                case .success(let todos):
                    DispatchQueue.main.async {
                        self?.todoItemsList = todos.list
                        self?.revision = todos.revision
                        self?.isDirty = false
                    }
                case .failure(let error):
                    DDLogInfo("Failed to fetch todos: \(error.localizedDescription)")
                }
            }
            
        default:
            load()
        }
        prepareDateSections()
    }
    
    func updateToDoList(toDoList: [TodoItem], revision: Int32) async {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            await apiService.updateToDoList(todoList: toDoList, revision: revision) { [weak self] result in
                switch result {
                case .success(let todos):
                    DispatchQueue.main.async {
                        self?.todoItemsList = todos.list
                        self?.revision = todos.revision
                    }
                case .failure(let error):
                    DDLogInfo("Failed to update to-do list: \(error.localizedDescription)")
                }
            }
        default:
            DDLogInfo("No network connectivity")
        }
    }
    
    func getToDoItem(id: String) async {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            Task {
                await apiService.getToDoItem(id: id) { [weak self] result in
                    switch result {
                    case .success(let todo):
                        DispatchQueue.main.async {
                            self?.todoItem = todo.element
                        }
                    case .failure(let error):
                        DDLogInfo("Failed to fetch todo item: \(error.localizedDescription)")
                    }
                }
            }
        default:
            DDLogInfo("No network connectivity")
        }
    }
    
    func addToDo(item: TodoItem, revision: Int32) async {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            Task {
                await apiService.addToDo(item: item, revision: revision) { [weak self] result in
                    switch result {
                    case .success(let newItem):
                        DispatchQueue.main.async {
                            self?.addItem(newItem.element)
                            self?.save()
                        }
                        DDLogInfo("Added new item")
                        
                    case .failure(let error):
                        DDLogInfo("Failed to add item: \(error)")
                    }
                }
            }
        default:
            self.addItem(item)
            isDirty = true
            save()
        }
    }
    
    func updateToDoItem(todoItem: TodoItem, revision: Int32) async {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            Task {
                await apiService.updateToDoItem(todoItem: todoItem, revision: revision) { [weak self] result in
                    switch result {
                    case .success(let item):
                        DispatchQueue.main.async {
                            if let index = self?.todoItemsList.firstIndex(where: { $0.id == item.element.id }) {
                                self?.todoItemsList[index] = item.element
                                self?.addItem(item.element)
                                self?.save()
                            }
                        }
                    case .failure(let error):
                        DDLogInfo("Failed to update todo item: \(error.localizedDescription)")
                    }
                }
            }
        default:
            self.addItem(todoItem)
            isDirty = true
            save()
        }
    }
    
    func deleteToDoItem(id: String, revision: Int32) async {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            Task {
                await apiService.deleteItem(id: id, revision: revision) { [weak self] result in
                    switch result {
                    case .success(let todo):
                        DispatchQueue.main.async {
                            self?.deletedItem = todo
                            self?.deleteItem(id: todo.id)
                            self?.save()
                            
                        }
                    case .failure(let error):
                        DDLogInfo("Failed to delete todo item: \(error.localizedDescription)")
                    }
                }
            }
        default:
            self.deleteItem(id: id)
            isDirty = true
            save()
        }
    }
    
    func load() {
        do {
            todoItemsList = try fileCache.load(fromJSON: "todoItems.json")
        } catch {
            todoItemsList = []
        }
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
            todoItemsList[index].done.toggle()
            Task {
                await updateToDoItem(todoItem: todoItemsList[index], revision: self.revision)
            }
        }
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
            if let deadline = todo.deadline {
                let formattedDeadline = ViewModel.formatDate(date: Date(timeIntervalSince1970: TimeInterval(deadline)), dateFormat: "d MMMM")!
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
