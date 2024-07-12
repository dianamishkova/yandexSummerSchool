//
//  TaskCellView.swift
//  ToDoList
//
//  Created by Диана Мишкова on 11.07.24.
//

import SwiftUI

struct TaskCellView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showTaskView: Bool
    var todoItem: TodoItem
    var body: some View {
        HStack {
            Button {
                viewModel.toggleCompleted(for: todoItem.id)
            } label: {
                Image(systemName: todoItem.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todoItem.completed ? .green : (todoItem.importance == .important ? .red : .gray))
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            HStack {
                VStack(alignment: .leading) {
                    Text(
                        todoItem.importance != .common ? "\(todoItem.importance.rawValue) \(todoItem.text)" : todoItem.text
                    )
                        .lineLimit(3)
                        .strikethrough(todoItem.completed, color: .gray)
                        .foregroundColor(todoItem.completed ? .gray : .primary)
                        .background(
                            NavigationLink(
                                "",
                                destination: TaskView(todoItem: todoItem, showDate: todoItem.deadline != nil)
                            )
                            .opacity(0)
                        )
                    if let deadline = todoItem.deadline {
                        HStack {
                            Image(systemName: "calendar")
                            Text(ViewModel.formatDate(date: deadline, dateFormat: "d MMMM") ?? "")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                Spacer()
                if let colorHex = todoItem.colorHex {
                    Circle()
                        .fill(colorHex)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                viewModel.toggleCompleted(for: todoItem.id)
            } label: {
                Label("Complete", systemImage: "checkmark.circle.fill")
            }
            .tint(.green)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.deleteItem(id: todoItem.id)
            } label: {
                Label("", systemImage: "trash.fill")
            }
            Button {
                showTaskView.toggle()
            } label: {
                Label("", systemImage: "info.circle")
            }
            .tint(.gray)
        }
    }
}
