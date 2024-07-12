import CocoaLumberjackSwift
import FileCachePackage
import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var uniqueDeadlines: [Date] = []
    @State var showTaskView = false
    @State private var showCompleted = true
    @State private var showCalendar = false
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Выполнено — \(viewModel.completedCount)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Button {
                        showCompleted.toggle()
                    } label: {
                        Text(showCompleted ? "Скрыть" : "Показать")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                List {
                    ForEach(viewModel.todoItemsList) { todoItem in
                        if showCompleted || !todoItem.completed {
                            TaskCellView(showTaskView: $showTaskView, todoItem: todoItem)
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showCalendar.toggle()
                            DDLogInfo("Navigated to CalendarView")
                        } label: {
                            Image(systemName: "calendar")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCalendar) {
                CalendarView(viewModel: viewModel)
            }
            .popover(isPresented: $showTaskView) {
                TaskView(
                    todoItem: TodoItem(
                        text: "",
                        importance: .common,
                        deadline: nil,
                        completed: false,
                        creationDate: Date.now,
                        editDate: Date.now
                    ),
                    showDate: false
                )
            }
            .modifier(FormBackgroundModifier())
        }
        .onAppear {
            viewModel.load()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(ViewModel())
}
