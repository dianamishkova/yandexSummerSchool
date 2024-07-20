import CocoaLumberjackSwift
import SwiftUI

struct TaskView: View {
    @Environment(\.dismiss)
    var dismiss
    @EnvironmentObject var viewModel: ViewModel
    @State var todoItem: TodoItem
    @State var showDatePicker = false
    @State var showDate: Bool
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

                Section {
                    VStack {
                        HStack {
                            Text("Важность")
                            Spacer()
                            Picker("Важность", selection: $todoItem.importance) {
                                ForEach(Importance.allCases, id: \.self) { importance in
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
                            if let colorHex = todoItem.color {
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .white)
                                    .frame(width: 20, height: 20)
                                    .padding()
                            }
                        }
                    }
                    .padding(4)
                    VStack(alignment: .leading) {
                        Toggle(isOn: $showDate) {
                            Text("Сделать до")
                        }
                        if showDate {
                            Button {
                                showDatePicker.toggle()
                            } label: {
                                Text(
                                    ViewModel.formatDate(
                                        date: Date(
                                            timeIntervalSince1970: TimeInterval(
                                                todoItem.deadline ?? 0
                                            )
                                        ),
                                        dateFormat: "d MMMM YYYY"
                                    ) ?? ""
                                )
                            }
                        }
                    }
                    .padding(4)
                    if showDatePicker {
                        DatePicker(
                            "Дата",
                            selection: Binding(
                                get: {
                                    Date(timeIntervalSince1970: TimeInterval(todoItem.deadline ?? 0))
                                },
                                set: { newValue in todoItem.deadline = Int64(newValue.timeIntervalSince1970) }
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
                            Task {
                                await viewModel.deleteToDoItem(id: todoItem.id, revision: viewModel.revision)
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
                    DDLogInfo("Navigated to MainView")
                },
                trailing: Button {
                    if !showDate {
                        todoItem.deadline = nil
                    }
                    Task {
                        if viewModel.todoItemsList.contains(where: { $0.id == todoItem.id}) {
                            await viewModel.updateToDoItem(todoItem: todoItem, revision: viewModel.revision)
                        } else {
                            await viewModel.addToDo(item: todoItem, revision: viewModel.revision)
                        }
                    }
                    dismiss()
                    DDLogInfo("Navigated to MainView")
                } label: {
                    Text("Сохранить")
                        .foregroundColor(todoItem.text.isEmpty ? .gray : .blue)
                }
                .disabled(todoItem.text.isEmpty)
            )
        }
        .onAppear {
            Task {
                await viewModel.getToDoItem(id: todoItem.id)
            }
        }
        .onChange(of: showDate) { newValue in
            if newValue {
                todoItem.deadline = Int64(Calendar.current.date(byAdding: .day, value: 1, to: Date())?.timeIntervalSince1970 ?? 0)
            } else {
                todoItem.deadline = nil
            }
        }
    }
}
