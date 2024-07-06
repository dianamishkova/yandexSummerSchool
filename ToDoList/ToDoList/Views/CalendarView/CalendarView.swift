import SwiftUI

struct CalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    let fileCache: FileCache
    var body: some View {
        NavigationView {
            CalendarViewControllerWrapper(fileCache: fileCache)
                .navigationBarTitle("Мои дела", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                })
        }
    }
}
