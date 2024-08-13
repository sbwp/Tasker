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
                    TaskView(task: task, date: date)
                } label: {
                    TaskGridView(task: task, date: date)
                        .contextMenu {
                            if task.isSnoozed(at: date) {
                                Button("Unsnooze") {
                                    task.unsnooze()
                                }
                            }
                            if !date.isEndOfDay {
                                Button("Snooze for 1 Hour") {
                                    task.snoozeOneHour(from: date)
                                }
                            }
                            Button("Snooze for 1 Day") {
                                task.snoozeOneDay(from: date)
                            }
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
