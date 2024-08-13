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
    @State var showCategories: [Bool] = [true, true, true, true]
    
    let categoryHeaderBackgrounds: [ColorOption] = [.yellow, .cyan, .lavender, .navy]
    
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
    
    var categories: [(String, [TaskerTask], Int)] {
        var categories: [(String, [TaskerTask], Int)] = [
            ("Morning Routine", [], 0),
            ("Daily Tasks", [], 1),
            ("Evening Routine", [], 2),
            ("Late Night", [], 3)
        ]
        
        for task in tasksToShow {
            if task.effectiveSortTime.lessThanByTimeOnly(TaskerTask.morningCutOff) {
                categories[0].1.append(task)
            } else if task.effectiveSortTime.lessThanByTimeOnly(TaskerTask.hygieneCutOff) {
                categories[1].1.append(task)
            } else if task.effectiveSortTime.lessThanByTimeOnly(TaskerTask.bedtimeCutOff) {
                categories[2].1.append(task)
            } else {
                categories[3].1.append(task)
            }
        }
        
        return categories
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
                
                ForEach(categories, id: \.0) { category in
                    if category.1.count > 0 {
                        HStack {
                            Spacer()
                            Text(category.0)
                            Spacer()
                            Image(systemName: showCategories[category.2] ? "chevron.down" : "chevron.up")
                        }
                        .font(.headline)
                        .padding()
                        .foregroundStyle(categoryHeaderBackgrounds[category.2].contrastingFontColor)
                        .background(categoryHeaderBackgrounds[category.2].color)
                        .cornerRadius(5)
                        .padding(.horizontal)
                        .onTapGesture {
                            showCategories[category.2].toggle()
                        }
                        if showCategories[category.2] {
                            TaskSectionView(date: date, tasks: category.1)
                                .padding(.top, 25)
                                .background(categoryHeaderBackgrounds[category.2].color.opacity(0.15))
                                .clipShape(.rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 5,
                                    bottomTrailingRadius: 5,
                                    topTrailingRadius: 0
                                ))
                                .padding(.horizontal)
                                .padding(.top, -25)
                                .padding(.bottom, 10)
                        }
                    }
                }
            }
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
