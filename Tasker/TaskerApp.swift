//
//  TaskerApp.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import SwiftUI
import SwiftData

@main
struct TaskerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskerTask.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
