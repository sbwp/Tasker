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
    @State var lastRefreshDate: Date = Date.practicallyNow
    @State var date: Date = Date.practicallyNow
    @State var hideByTime: Bool = true
    @State var showDoneSkipped: Bool = false
    
    var tasksToShow: [TaskerTask] {
        let r: [TaskerTask] = taskListViewType == .all
            ? tasks
            : tasks.filter({
                (showDoneSkipped || !$0.isDoneOrPredone(on: date) && !$0.isSkipped(on: date))
                && $0.occurs(on: date, includeMissed: true)
                && (!hideByTime || $0.shouldShow(at: date) || !$0.occurs(on: date, includeMissed: false))
            })
        
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
                .onChange(of: taskListViewType, { updateDates(force: true) })
                .onChange(of: scenePhase, { updateDates() })
                .onAppear() {
                    updateDates(force: true)
                    tasks.forEach { task in
                        task.doMaintenance()
                    }
                }
                
                if taskListViewType == .day {
                    DatePicker("Date to Show", selection: $date, displayedComponents: [.date])
                        .padding(.horizontal, 25)
                        .padding(.bottom, 10)
                } else if taskListViewType == .dueNow {
                    Toggle("Hide By Time", isOn: $hideByTime)
                        .tint(.green)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 10)
                }
                
                if taskListViewType != .all {
                    Toggle("Show Done/Skipped", isOn: $showDoneSkipped)
                        .tint(.green)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 10)
                }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: TaskerConfig.tileWidth))], spacing: 15) {
                    ForEach(tasksToShow, id: \.self) { task in
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
    
    private func updateDates(force: Bool = false) -> Void {
        let then = lastRefreshDate
        lastRefreshDate = .practicallyNow
        
        if force || !lastRefreshDate.isSameDay(as: then) && lastRefreshDate.isSameDay(as: date) {
            date = lastRefreshDate
        }
    }
}

#Preview {
    return ContentView()
        .modelContainer(.forPreview)
}
