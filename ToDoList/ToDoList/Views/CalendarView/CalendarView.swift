import CocoaLumberjackSwift
import SwiftUI

struct CalendarView: View {
    @Environment(\.presentationMode) 
    var presentationMode
    let viewModel: ViewModel
    var body: some View {
        NavigationView {
            CalendarViewControllerWrapper(viewModel: viewModel)
                .navigationBarTitle("Мои дела", displayMode: .inline)
                .navigationBarItems(leading: 
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        DDLogInfo("Navigated to MainView")
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                    })
        }
    }
}
