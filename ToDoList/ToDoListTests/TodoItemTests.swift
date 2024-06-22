//
//  TodoItemTests.swift
//  ToDoListTests
//
//  Created by Диана Мишкова on 22.06.24.
//

import XCTest
@testable import ToDoList

class TodoItemTests: XCTestCase {

    
    func testTodoItemDefaultInitialization() {
        let text = "Test task"
        let todoItem = TodoItem(text: text)
        
        XCTAssertEqual(todoItem.text, text)
        XCTAssertEqual(todoItem.importance, .common)
        XCTAssertNil(todoItem.deadline)
        XCTAssertEqual(todoItem.completed, false)
        XCTAssertNotNil(todoItem.creationDate)
        XCTAssertNil(todoItem.editDate)
    }
    
    func testTodoItemJSONConversion() {
        let deadline = Date(timeIntervalSince1970: 1822548800)
        let creationDate = Date(timeIntervalSince1970: 1622548800)
        let editDate = Date(timeIntervalSince1970: 1622548800)
        
        let todoItem = TodoItem(
            id: "1",
            text: "Test task",
            importance: .important,
            deadline: deadline,
            completed: true,
            creationDate: creationDate,
            editDate: editDate
        )
        
        let json = todoItem.json as! [String: Any]
        
        XCTAssertEqual(json["id"] as? String, "1")
        XCTAssertEqual(json["text"] as? String, "Test task")
        XCTAssertEqual(json["importance"] as? String, "важная")
        XCTAssertEqual(json["deadline"] as? TimeInterval, deadline.timeIntervalSince1970)
        XCTAssertEqual(json["completed"] as? Bool, true)
        XCTAssertEqual(json["creationDate"] as? TimeInterval, creationDate.timeIntervalSince1970)
        XCTAssertEqual(json["editDate"] as? TimeInterval, editDate.timeIntervalSince1970)
    }
    
    func testTodoItemJSONParsing() {
        let json: [String: Any] = [
            "id": "1",
            "text": "Test task",
            "importance": "важная",
            "deadline": 1822548800.0,
            "completed": true,
            "creationDate": 1622548800.0,
            "editDate": 1622548800.0
        ]
        
        guard let todoItem = TodoItem.parse(json: json) else {
            XCTFail("Failed to parse TodoItem from JSON")
            return
        }
        
        XCTAssertEqual(todoItem.id, "1")
        XCTAssertEqual(todoItem.text, "Test task")
        XCTAssertEqual(todoItem.importance, .important)
        XCTAssertEqual(todoItem.deadline, Date(timeIntervalSince1970: 1822548800))
        XCTAssertEqual(todoItem.completed, true)
        XCTAssertEqual(todoItem.creationDate, Date(timeIntervalSince1970:  1622548800))
        XCTAssertEqual(todoItem.editDate, Date(timeIntervalSince1970: 1622548800))
    }
    
    func testTodoItemCSVParsing() {
        let csv = "1,\"Test task, with comma\",важная,1822548800.0,true,1622548800,1622548800.0"
        
        guard let todoItem = TodoItem.parse(csv: csv) else {
            XCTFail("Failed to parse TodoItem from CSV")
            return
        }
        
        XCTAssertEqual(todoItem.id, "1")
        XCTAssertEqual(todoItem.text, "Test task, with comma")
        XCTAssertEqual(todoItem.importance, .important)
        XCTAssertEqual(todoItem.deadline, Date(timeIntervalSince1970: 1822548800))
        XCTAssertEqual(todoItem.completed, true)
        XCTAssertEqual(todoItem.creationDate, Date(timeIntervalSince1970: 1622548800))
        XCTAssertEqual(todoItem.editDate, Date(timeIntervalSince1970: 1622548800))
    }
    
    func testTodoItemCSVParsingWithoutQuotes() {
        let csv = "1,Test task,важная,,true,1640920800,"
        
        guard let todoItem = TodoItem.parse(csv: csv) else {
            XCTFail("Failed to parse TodoItem from CSV")
            return
        }
            
        XCTAssertEqual(todoItem.id, "1")
        XCTAssertEqual(todoItem.text, "Test task")
        XCTAssertEqual(todoItem.importance, .important)
        XCTAssertNil(todoItem.deadline)
        XCTAssertEqual(todoItem.completed, true)
        XCTAssertEqual(todoItem.creationDate, Date(timeIntervalSince1970: 1640920800))
        XCTAssertNil(todoItem.editDate)
    }
}
