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
                                HStack{
                                    VStack(alignment: .leading) {
                                        Text(todoItem.importance != .common ? "\(todoItem.importance.rawValue) \(todoItem.text)" : todoItem.text)
                                            .lineLimit(3)
                                            .strikethrough(todoItem.completed, color: .gray)
                                            .foregroundColor(todoItem.completed ? .gray : .primary)
                                            .background(
                                                NavigationLink("", destination: TaskView(todoItem: todoItem, showDatePicker: todoItem.deadline != nil))
                                                    .opacity(0)
                                            )
                                        if let deadline = todoItem.deadline {
                                            HStack {
                                                Image(systemName: "calendar")
                                                Text(fileCache.formatDate(date: deadline, dateFormat: "dd MMMM"))
                                            }
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    if let colorHex = todoItem.colorHex  {
                                        Circle()
                                            .fill(colorHex)
                                            .frame(width: 20, height: 20)
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
                .navigationTitle("Мои дела")
            }
            .navigationDestination(isPresented: $showTaskView) {
                TaskView(todoItem: TodoItem(text: "", importance: .common, deadline: nil/*Calendar.current.date(byAdding: .day, value: 1, to: Date.now)*/, completed: false, creationDate: Date.now, editDate: Date.now), showDatePicker: false)
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

