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
                Image(systemName: todoItem.done ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todoItem.done ? .green : (todoItem.importance == .important ? .red : .gray))
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            HStack {
                VStack(alignment: .leading) {
                    Text(
                        todoItem.importance != .basic ? "\(todoItem.importance.rawValue) \(todoItem.text)" : todoItem.text)
                        .lineLimit(3)
                        .strikethrough(todoItem.done, color: .gray)
                        .foregroundColor(todoItem.done ? .gray : .primary)
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
                            Text(
                                ViewModel.formatDate(
                                    date: Date(
                                        timeIntervalSince1970: TimeInterval(
                                            deadline
                                        )
                                    ),
                                    dateFormat: "d MMMM"
                                ) ?? ""
                            )
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                Spacer()
                if let colorHex = todoItem.color {
                    Circle()
                        .fill(Color(hex: colorHex) ?? .white)
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
                Task {
                    await viewModel.deleteToDoItem(id: todoItem.id, revision: viewModel.revision)
                }
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
