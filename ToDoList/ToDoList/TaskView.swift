import SwiftUI

struct TaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var fileCache: FileCache
    @State var todoItem: TodoItem
    @State var showDatePicker: Bool
    @State private var showColorPicker = false
    @State private var selectedColor = Color.white
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ZStack(alignment: .topLeading) {
                        if todoItem.text.isEmpty {
                            Text("Что надо сделать?")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: $todoItem.text)
                            .frame(minHeight: 100)
                    }
                }
                .background(Color("SecondaryBack"))

                Section {
                    VStack {
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
                        
                        HStack {
                            Button("Выбрать цвет") {
                                showColorPicker = true
                            }
                            Spacer()
                            if let colorHex = todoItem.colorHex  {
                                Circle()
                                    .fill(colorHex)
                                    .frame(width: 20, height: 20)
                                    .padding()
                            }
                        }
                    }
                    .padding(4)
                    VStack(alignment: .leading) {
                        Toggle(isOn: $showDatePicker) {
                            Text("Сделать до")
                        }
                        if showDatePicker {
                            Button {
                                showDatePicker.toggle()
                            } label: {
                                Text(fileCache.formatDate(date: todoItem.deadline ?? Date(), dateFormat: "dd MMMM YYYY"))
                            }
                        }
                    }
                    .padding(4)
                    if showDatePicker {
                        DatePicker(
                            "Дата",
                            selection: Binding(
                                get: {
                                    todoItem.deadline ?? Date()
                                },
                                set: { newValue in todoItem.deadline = newValue }
                            ),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    
                }
                .background(Color("SecondaryBack"))

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
                                .foregroundColor(todoItem.text.isEmpty ? .gray : .red)
                        }
                        .disabled(todoItem.text.isEmpty)
                        .padding(8)
                        Spacer()
                    }
                }
                .background(Color("SecondaryBack"))
            }
            .navigationDestination(isPresented: $showColorPicker) {
                ColorPicker(selectedColor: selectedColor, todoItem: todoItem)
            }
            .modifier(FormBackgroundModifier())
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отменить") {
                    dismiss()
                },
                trailing: Button {
                    fileCache.addItem(todoItem)
                    do {
                        try fileCache.save(to: "todoItems.json")
                    } catch {
                        print("Error saving data: \(error)")
                    }
                    dismiss()
                } label: {
                    Text("Сохранить")
                        .foregroundColor(todoItem.text.isEmpty ? .gray : .blue)
                }
                .disabled(todoItem.text.isEmpty)
            )
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: showDatePicker) {
            todoItem.deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        }
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

#Preview {
    TaskView(todoItem: TodoItem(id: "1", text: "Купить что-то", importance: .important, completed: false, creationDate: Date(timeIntervalSince1970: 1822548800)), showDatePicker: false)
        .environmentObject(FileCache())
}
