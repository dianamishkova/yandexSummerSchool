import SwiftUI

struct MainView: View {
    @EnvironmentObject var fileCache: FileCache
    @State var showTaskView: Bool = false
    @State private var showCompleted = true

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Выполнено — \(fileCache.completedCount)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: {
                        showCompleted.toggle()
                    }) {
                        Text(showCompleted ? "Скрыть" : "Показать")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                List {
                    ForEach(fileCache.todoItemsList) { todoItem in
                        if showCompleted || !todoItem.completed {
                            HStack {
                                Button {
                                    fileCache.toggleCompleted(for: todoItem.id)
                                } label: {
                                    Image(systemName: todoItem.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todoItem.completed ? .green : (todoItem.importance == .important ? .red : .gray))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(Rectangle())
                                
                                VStack(alignment: .leading) {
                                    NavigationLink(destination: TaskView(todoItem: todoItem)) {
                                        Text(todoItem.importance != .common ? "\(todoItem.importance.rawValue) \(todoItem.text)" : todoItem.text)
                                            .lineLimit(3)
                                            .strikethrough(todoItem.completed, color: .gray)
                                            .foregroundColor(todoItem.completed ? .gray : .primary)
                                    }
                                    if let deadline = todoItem.deadline {
                                        HStack {
                                            Image(systemName: "calendar")
                                            Text(fileCache.formatDate(date: deadline))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    fileCache.toggleCompleted(for: todoItem.id)
                                } label: {
                                    Label("Complete", systemImage: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    fileCache.deleteItem(id: todoItem.id)
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
                }
                .listRowBackground(Color("SecondaryBack"))
                
                
                
                Button {
                    showTaskView.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                }
                .navigationDestination(isPresented: $showTaskView) {
                    TaskView(todoItem: TodoItem(text: "", importance: .common, deadline: Calendar.current.date(byAdding: .day, value: 1, to: Date.now), completed: false, creationDate: Date.now, editDate: Date.now))
                }
                .navigationTitle("Мои дела")
            }
            .modifier(FormBackgroundModifier())
        }
        .onAppear {
            do {
                try fileCache.load(fromJSON: "todoItems.json")
            } catch {
                print(error)
            }
        }
    }
}



#Preview {
    MainView()
        .environmentObject(FileCache())
}

