//
//  CalendarViewControllerWrapper.swift
//  ToDoList
//
//  Created by Диана Мишкова on 2.07.24.
//

import SwiftUI

struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = CalendarViewController
    
    var viewModel: ViewModel
    
    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
    }
}
