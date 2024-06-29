import SwiftUI

struct TaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var fileCache: FileCache
    @State var todoItem: TodoItem
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ZStack(alignment: .topLeading) {
                        if todoItem.text.isEmpty {
                            Text("Введите задачу")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: $todoItem.text)
                            .frame(minHeight: 100)
                    }
                }

                Section {
                    HStack {
                        Text("Важность")
                        Spacer()
                        Picker("Важность", selection: $todoItem.importance) {
                            ForEach(Importance.allCases) { importance in
                                Text(importance.rawValue).tag(importance)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 150)
                    }
                    
                    Toggle(isOn: $showDatePicker) {
                        Text("Сделать до")
                    }
                    
                    if showDatePicker {
                        DatePicker(
                            "Дата",
                            selection: Binding(
                                get: { todoItem.deadline ?? Date() },
                                set: { newValue in todoItem.deadline = newValue }
                            ),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Button(role: .destructive) {
                            fileCache.deleteItem(id: todoItem.id)
                            do {
                                try fileCache.save(to: "todoItems.json")
                            } catch {
                                print("Error saving data: \(error)")
                            }
                            dismiss()
                        } label: {
                            Text("Удалить")
                                .foregroundColor(.red)
                        }
                        .disabled(todoItem.text.isEmpty)
                        Spacer()
                    }
                }
            }
            .modifier(FormBackgroundModifier())
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отменить") {
                    dismiss()
                },
                trailing: Button("Сохранить") {
                    fileCache.addItem(todoItem)
                    do {
                        try fileCache.save(to: "todoItems.json")
                    } catch {
                        print("Error saving data: \(error)")
                    }
                    dismiss()
                }
            )
        }
    }
}


#Preview {
    TaskView(todoItem: TodoItem(id: "1", text: "Купить что-то", importance: .important, completed: false, creationDate: Date(timeIntervalSince1970: 1822548800)))
        .environmentObject(FileCache())
}
