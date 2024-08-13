//
//  TaskerTask.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import Foundation
import SwiftData

@Model
final class TaskerTask: Identifiable, Comparable {
    static func < (lhs: TaskerTask, rhs: TaskerTask) -> Bool {
        let lst = lhs.effectiveSortTime
        let rst = rhs.effectiveSortTime
        if !lst.equalByTimeOnly(rst) {
            return lst.lessThanByTimeOnly(rst)
        }
        return lhs.name < rhs.name
    }
    
    static let morningCutOff = Date().setTime(hour: 9, minute: 0, second: 0)
    static let hygieneCutOff = Date().setTime(hour: 22, minute: 0, second: 0)
    static let bedtimeCutOff = Date().setTime(hour: 23, minute: 0, second: 0)
    
    let id: UUID
    var name: String
    var colorOption: ColorOption
    var repeatConfig: RepeatConfig
    var completedDates: [Date]
    var skippedDates: [Date]
    var showAfter: Date?
    var doEarlyDays: Int
    var doLateDays: Int
    var notes: String
    var sortTime: Date?
    
    var effectiveSortTime: Date {
        sortTime ?? showAfter ?? .practicallyNow.startOfDay
    }
    
    static var forPreview: TaskerTask {
        TaskerTask(name: "Test")
    }
    
    init(name: String, colorOption: ColorOption? = nil, repeatConfig: RepeatConfig? = nil, showAfter: Date? = nil, notes: String = "", sortTime: Date? = nil, doEarlyDays: Int = 0, doLateDays: Int = 365) {
        self.id = UUID()
        self.name = name
        self.colorOption = colorOption ?? ColorOption.allCases.randomElement()!
        self.repeatConfig = repeatConfig ?? RepeatConfig(unit: .days, frequency: 1, startDate: Date.practicallyNow.noon)
        self.completedDates = []
        self.skippedDates = []
        self.showAfter = showAfter
        self.notes = notes
        self.sortTime = sortTime
        self.doEarlyDays = doEarlyDays
        self.doLateDays = doLateDays
    }
    
    // Gets run for each task on startup
    // Useful for adding new non-optional fields to the model
    // Example: Add a field called stuffCount as a non-optional Int with a default value of 10
    // Step 1: Add a new field with the final name, but optional: var stuffCount: Int?
    //     Make sure to assign it in the initializer. You should be able to write this as if it is not optional.
    // Step 2: Add a computed variable backed by this value that is not optional:
    //     var stuffCountX: Int {
    //         get { stuffCount ?? 0 }
    //         set { stuffCount = newValue }
    //     }
    // Step 3: In doMaintenance add a step to initialize it to the desired default value: stuffCount = 5
    // Step 4: (optional) implement the feature using the variable
    // Step 5: Compile and run and make sure it works the way you like
    // Step 6: Make the variable not optional: var stuffCount: Int
    // Step 7: Compile and run and make sure the app loads with the change.
    // Step 8: Comment out the getter and initialization code
    // Step 9: Rename the variable to the getter's name: var stuffCountX: Int
    // Step 10: Refactor > Rename the variable to the original name: var stuffCount: Int
    // Step 11: That should resolve the remaining errors. Compile and run again.
    // If it works, you can go ahead and clean up the commented-out code
    func doMaintenance() -> Void {
        // Example: self.newField = value
    }
    
    func shouldShow(at time: Date) -> Bool {
        return showAfter == nil || time.greaterThanByTimeOnly(showAfter!)
    }
    
    func occurs(on date: Date, includeMissed: Bool = false) -> Bool {
        if repeatConfig.occursOn(date.noon) {
            return true
        }
        
        if !includeMissed || doLateDays == 0 || date.noon < repeatConfig.startDate.startOfDay || (repeatConfig.endDate != nil && date.startOfDay > repeatConfig.endDate!.noon) {
            return false
        }
        
        var current = date.yesterday
        
        while current.noon > repeatConfig.startDate.startOfDay && Date.daysBetween(current, and: date) <= doLateDays {
            if isDone(on: current) || isSkipped(on: current) {
                return false
            } else if repeatConfig.occursOn(current) {
                return true
            }
            current = current.yesterday
        }
        
        return false
    }
    
    func nextOccurrenceDescription(at date: Date) -> String {
        let result = repeatConfig.nextOccurrence(from: date)
        
        if result.isSameDay(as: date) {
            return "Today"
        } else if result.isSameDay(as: date.tomorrow) {
            return "Tomorrow"
        }
        
        if date.isInSameWeek(as: result) {
            return result.dayOfWeekEnum.description
        } else if date.addDays(7).isInSameWeek(as: result) {
            return "Next \(result.dayOfWeekEnum.description)"
        }
        
        return result.formatted(year: date.isInSameYear(as: result) ? .none : .full, month: .short, day: .full)
    }
    
    func isDone(on date: Date) -> Bool {
        return completedDates.contains(date.noon)
    }
    
    func isPredone(before date: Date) -> Bool {
        var current = date.yesterday
        
        while current.noon > repeatConfig.startDate.startOfDay && Date.daysBetween(current, and: date) <= doEarlyDays {
            if isDone(on: current) {
                return true
            }
            current = current.yesterday
        }
        return false
    }
    
    func isDoneOrPredone(on date: Date) -> Bool {
        return isDone(on: date) || isPredone(before: date)
    }
    
    func isSkipped(on date: Date) -> Bool {
        return skippedDates.contains(date.noon)
    }
    
    func getStatus(for date: Date) -> TaskStatus {
        if isDone(on: date) {
            return .completed
        } else if isSkipped(on: date) {
            return .skipped
        }
        
        if !occurs(on: date, includeMissed: false) {
            return (date.isTodayOrPast && occurs(on: date, includeMissed: true)) ? .overdue : .unscheduled
        }
        
        var current = date.yesterday
        
        while current.noon > repeatConfig.startDate.startOfDay && Date.daysBetween(current, and: date) <= doEarlyDays && !occurs(on: current, includeMissed: false) {
            if isDone(on: current) || isSkipped(on: current) {
                return .unscheduled
            }
            current = current.yesterday
        }
        
        current = date.tomorrow
        
        while (repeatConfig.endDate == nil || current.startOfDay < repeatConfig.endDate!.noon) && Date.daysBetween(date, and: current) <= doLateDays && !occurs(on: current, includeMissed: false) {
            if isDone(on: current) || isSkipped(on: current) {
                return .delayed
            }
            current = current.tomorrow
        }
        
        return date.isTodayOrFuture ? .scheduled : .missed
    }
    
    func toggleSkipped(on date: Date) -> Void {
        if isSkipped(on: date) {
            markUnskipped(on: date)
        } else {
            markSkipped(on: date)
        }
    }
    
    func markSkipped(on date: Date) -> Void {
        skippedDates.append(date.noon)
        skippedDates.sort()
        skippedDates.reverse()
        
        completedDates.removeAll {
            $0.isSameDay(as: date.noon)
        }
    }
    
    func markUnskipped(on date: Date) -> Void {
        skippedDates.removeAll {
            $0.isSameDay(as: date.noon)
        }
    }
    
    func toggle(on date: Date) -> Void {
        if isDone(on: date) {
            markUndone(on: date)
        } else {
            markDone(on: date)
        }
    }
    
    func markDone(on date: Date) -> Void {
        completedDates.append(date.noon)
        completedDates.sort()
        completedDates.reverse()
        
        skippedDates.removeAll {
            $0.isSameDay(as: date.noon)
        }
    }
    
    func markUndone(on date: Date) -> Void {
        completedDates.removeAll {
            $0.isSameDay(as: date.noon)
        }
    }
}
