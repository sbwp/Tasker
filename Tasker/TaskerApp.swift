//
//  TaskerApp.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import SwiftUI

@main
struct TaskerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: TaskerDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
