//
//  ContentView.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: TaskerDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(TaskerDocument()))
}
