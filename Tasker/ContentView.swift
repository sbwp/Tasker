//
//  ContentView.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Query var tasks: [TaskerTask]
    @State var taskListViewType: TaskListViewType = .dueNow
    @State var now: Date = Date.practicallyNow
    
    var tasksToShow: [TaskerTask] {
        let r = switch taskListViewType {
        case .all:
            tasks
        case .today:
            tasks.filter({ $0.occurs(on: now, includeMissed: true) })
        case .dueNow:
            tasks.filter({ !$0.isDoneOrPredone(on: now) && !$0.isSkipped(on: now) && $0.occurs(on: now, includeMissed: true) && ($0.shouldShow(at: now) || !$0.occurs(on: now, includeMissed: false)) })
        }
        
        return r.sorted()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Picker("Which Tasks to View", selection: $taskListViewType) {
                    ForEach(TaskListViewType.allCases, id: \.self) { viewType in
                        Text(viewType.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom)
                .onChange(of: taskListViewType) {
                    now = Date.practicallyNow
                }
                .onAppear() {
                    now = Date.practicallyNow
                    tasks.forEach { task in
                        task.doMaintenance()
                    }
                }
                .onChange(of: scenePhase) {
                    now = Date.practicallyNow
                }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: TaskerConfig.tileWidth))], spacing: 15) {
                    ForEach(tasksToShow, id: \.self) { task in
                        NavigationLink {
                            TaskView(task: task, now: now)
                        } label: {
                            TaskGridView(task: task, now: now)
                                .contextMenu {
                                    Button(task.isSkipped(on: now) ? "Mark Unskipped" : "Mark Skipped") {
                                        task.toggleSkipped(on: now)
                                    }
                                    Button("Delete", role: .destructive) {
                                        modelContext.delete(task)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Tasker")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("+") {
                            modelContext.insert(TaskerTask(name: "Untitled"))
                        }
                        .font(.system(size: 24))
                        .bold()
                    }
                }
            }
        }.tint(.primary)
    }
}

#Preview {
    return ContentView()
        .modelContainer(.forPreview)
}
