//
//  FormBackgroundModifier.swift
//  ToDoList
//
//  Created by Диана Мишкова on 29.06.24.
//

import SwiftUI

struct FormBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("PrimaryBack"))
            .scrollContentBackground(.hidden)
    }
}
