//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Диана Мишкова on 15.06.24.
//
import CocoaLumberjackSwift
import SwiftUI

@main
struct ToDoListApp: App {    
    init() {
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(ViewModel())
        }
    }
}
