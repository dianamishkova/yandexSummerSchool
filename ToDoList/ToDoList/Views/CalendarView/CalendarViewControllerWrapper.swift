//
//  CalendarViewControllerWrapper.swift
//  ToDoList
//
//  Created by Диана Мишкова on 2.07.24.
//

import SwiftUI

struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    var fileCache: FileCache
    typealias UIViewControllerType = CalendarViewController

    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController(fileCache: fileCache)
    }

    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
    }
}
