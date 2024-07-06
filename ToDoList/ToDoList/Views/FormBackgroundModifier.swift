import SwiftUI

struct FormBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("PrimaryBack"))
            .scrollContentBackground(.hidden)
    }
}
