//
//  UndistractedRoutineApp.swift
//  UndistractedRoutine
//
//  Created by Efe Mesudiyeli on 5.03.2025.
//

import SwiftUI

@main
struct UndistractedRoutineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
