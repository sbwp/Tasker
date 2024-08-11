//
//  ModelContainer.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/20/24.
//

import Foundation
import SwiftData

extension ModelContainer {
    static var forPreview: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: TaskerTask.self, configurations: config)
    }
}
