// ©2024 Sabrina Bea. All rights reserved.

import SwiftUI

struct TaskSectionView: View {
    @Environment(\.modelContext) private var modelContext
    var date: Date
    var tasks: [TaskerTask]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: TaskerConfig.tileWidth))], spacing: 15) {
            ForEach(tasks, id: \.self) { task in
                NavigationLink {
                    TaskView(task: task, now: date)
                } label: {
                    TaskGridView(task: task, now: date)
                        .contextMenu {
                            Button(task.isSkipped(on: date) ? "Mark Unskipped" : "Mark Skipped") {
                                task.toggleSkipped(on: date)
                            }
                            Button("Delete", role: .destructive) {
                                modelContext.delete(task)
                            }
                        }
                }
            }
        }
        .padding(.bottom)
    }
}

#Preview {
    TaskSectionView(date: .practicallyNow, tasks: [.forPreview])
        .modelContainer(.forPreview)
}
