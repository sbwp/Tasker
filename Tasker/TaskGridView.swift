// ©2024 Sabrina Bea. All rights reserved.

import SwiftUI

struct TaskGridView: View {
    @Bindable var task: TaskerTask
    var date: Date
    
    var timeText: String {
        if let showAfter = task.showAfter {
            return " after \(showAfter.formattedAsTime)"
        } else {
            return ""
        }
    }
    
    var statusText: String {
        if task.isDone(on: date) {
            return "Good job!"
        } else if task.isPredone(before: date) {
            return "Done early, nice!"
        } else if date.isToday && task.isSnoozed(at: date) {
            return "Snoozed until \(task.snoozeText)"
        } else if task.occurs(on: date, includeMissed: false) {
            return "Due now"
        } else {
            return "Overdue"
        }
    }
    
    var body: some View {
        VStack {
            Text(task.name)
                .font(.system(size: 24, weight: .bold))
            
            Spacer(minLength: 0)
            
            if (task.occurs(on: date, includeMissed: true)) {
                TaskStatusButton(task: task, now: date)
                Spacer(minLength: 0)
                Text(statusText)
            } else {
                Text("\(task.repeatConfig.description)\(timeText)")
                    .opacity(0.8)
                
                Spacer(minLength: 0)
                
                Text("(\(task.nextOccurrenceDescription(at: date)))")
                    .opacity(0.6)
            }
        }
        .padding()
        .frame(width: TaskerConfig.tileWidth, height: TaskerConfig.tileWidth, alignment: .center)
        .background(task.colorOption.color)
        .foregroundStyle(task.colorOption.contrastingFontColor)
        .cornerRadius(20)
        
    }
}

#Preview {
    TaskGridView(task: .forPreview, date: .practicallyNow)
}
