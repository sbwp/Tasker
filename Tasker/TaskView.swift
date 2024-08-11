//
//  TaskView.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/20/24.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.editMode) var editModeWrapper
    @Bindable var task: TaskerTask
    @State var showNotes: Bool = true
    var now: Date
    
    var editMode: EditMode {
        editModeWrapper?.wrappedValue ?? .inactive
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    if (editMode == .active) {
                        TextField("Name", text: $task.name)
                            .onAppear() {
                                UITextField.appearance().clearButtonMode = .whileEditing
                            }
                    } else {
                        Text(task.name)
                        Spacer()
                    }
                }
                .font(.title)
                .fontWeight(.bold)
                
                if (editMode == .active) {
                    HStack {
                        Text("Color:")
                            .padding(.trailing, 20)
                        ColorOptionPicker(colorOption: $task.colorOption)
                        Spacer()
                    }
                }
                
                if (editMode == .active) {
                    if task.repeatConfig.unit != .days || task.repeatConfig.frequency != 1 {
                        HStack {
                            Text("Days to Do Early")
                            Spacer()
                            TextField("Days Allowed Early", value: $task.doEarlyDays, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Days to Do Late")
                            Spacer()
                            TextField("Days Allowed Late", value: $task.doLateDays, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    DatePicker("Start Date", selection: $task.repeatConfig.startDate, displayedComponents: [.date])
                    Toggle("Has End Date", isOn: Binding(
                        get: { task.repeatConfig.endDate != nil },
                        set: {
                            if $0 {
                                if task.repeatConfig.endDate == nil {
                                    task.repeatConfig.endDate = Date.practicallyNow.add(1, .year)
                                }
                            } else {
                                task.repeatConfig.endDate = nil
                            }
                        }
                    ))
                    .tint(task.colorOption.successColor)
                    if task.repeatConfig.endDate != nil {
                        DatePicker("End Date", selection: Binding(get: { task.repeatConfig.endDate ?? Date.practicallyNow.add(1, .year)}, set: { task.repeatConfig.endDate = $0 }), displayedComponents: [.date])
                    }
                    RepeatField(repeatConfig: $task.repeatConfig)
                    
                    Toggle("Hide Until Time", isOn: Binding(
                        get: { task.showAfter != nil },
                        set: {
                            if $0 {
                                if task.showAfter == nil {
                                    task.showAfter = Date.practicallyNow.noon
                                }
                            } else {
                                task.showAfter = nil
                            }
                        }
                    ))
                    .tint(task.colorOption.successColor)
                    if task.showAfter != nil {
                        DatePicker("Show After Time", selection: Binding(get: { task.showAfter ?? Date.practicallyNow.noon}, set: { task.showAfter = $0 }), displayedComponents: [.hourAndMinute])
                    }
                    
                    Toggle("Sort By Estimated Time", isOn: Binding(
                        get: { task.sortTime != nil },
                        set: {
                            if $0 {
                                if task.sortTime == nil {
                                    task.sortTime = Date.practicallyNow.noon
                                }
                            } else {
                                task.sortTime = nil
                            }
                        }
                    ))
                    .tint(task.colorOption.successColor)
                    if task.sortTime != nil {
                        DatePicker("Estimated Time", selection: Binding(get: { task.sortTime ?? Date.practicallyNow.noon}, set: { task.sortTime = $0 }), displayedComponents: [.hourAndMinute])
                    }
                } else {
                    HStack {
                        Text("\(task.repeatConfig.description)\(task.showAfter == nil ? "" : " after \(task.showAfter!.formattedAsTime)")")
                        Spacer()
                    }
                }
                
                if (editMode != .active) {
                    if (task.occurs(on: now, includeMissed: true)) {
                        TaskStatusButton(task: task, now: now)
                            .contextMenu {
                                Button(task.isSkipped(on: now) ? "Mark Unskipped" : "Mark Skipped") {
                                    task.toggleSkipped(on: now)
                                }
                            }
                    }
                    
                    CalendarView(task: task)
                    
                    DisclosureGroup("History") {
                        VStack {
                            ForEach(task.completedDates, id: \.self) { date in
                                Text(date.formatted(year: .long, month: .long, day: .long, weekday: .long))
                            }
                        }
                    }
                    
                }
                
                if (editMode == .active) {
                    TextField("Add Notes", text: $task.notes,  axis: .vertical)
                        .lineLimit(5...)
                        .padding()
                        .border(task.colorOption.contrastingFontColor, width: 1, cornerRadius: 5)
                } else {
                    HStack {
                        Text("Notes")
                            .font(.headline)
                        Spacer(minLength: 0)
                    }
                    HStack {
                        Text(task.notes)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                }
                
                Spacer()
            }
        }
        .foregroundStyle(task.colorOption.contrastingFontColor)
        .navigationTitle(editMode == .active ? "Edit Task" : "View Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .padding()
        .background(task.colorOption.color)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        TaskView(task: TaskerTask.forPreview, now: .practicallyNow)
            .modelContainer(.forPreview)
    }
}
