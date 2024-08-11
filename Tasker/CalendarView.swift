// ©2024 Sabrina Bea. All rights reserved.

import SwiftUI

struct CalendarView: View {
    @State var year: Int = Date.practicallyNow.year
    @State var month: Int = Date.practicallyNow.month
    
    @Bindable var task: TaskerTask
    
    var body: some View {
        VStack {
            HStack {
                Button("", systemImage: "chevron.left") {
                    if month == 1 {
                        month = 12
                        year -= 1
                    } else {
                        month -= 1
                    }
                }
                .padding(.leading, 42)
                .accessibilityLabel("Previous Month")
                
                Spacer()
                
                Button("\(MonthOfYear(rawValue: month)!.description) \(String(year))") {
                    year = Date.practicallyNow.year
                    month = Date.practicallyNow.month
                }
                
                Spacer()
                
                Button("", systemImage: "chevron.right") {
                    if month == 12 {
                        month = 1
                        year += 1
                    } else {
                        month += 1
                    }
                }
                .padding(.trailing, 35)
                .accessibilityLabel("Next Month")
            }
            .font(.system(size: 24, weight: .bold))
            .padding()
            
            HStack(spacing: 31.5) {
                ForEach (DayOfWeek.allCases, id: \.self) { day in
                    Text(day.description.first!.description)
                }
            }
            
            ForEach(Array(Date.get2DArray(of: month, in: year).enumerated()), id: \.0) { _, week in
                HStack {
                    ForEach(Array(week.enumerated()), id: \.0) { _, date in
                        if let date = date {
                            VStack {
                                statusImage(for: date)
                                Text(String(date.dayOfMonth))
                            }
                            .padding(5)
                            .border(.black, width: 1, cornerRadius: 5)
                            .frame(width: 35)
                            .contextMenu {
                                Button(task.isDone(on: date) ? "Mark Uncompleted" : "Mark Completed") {
                                    task.toggle(on: date)
                                }
                                Button(task.isSkipped(on: date) ? "Mark Unskipped" : "Mark Skipped") {
                                    task.toggleSkipped(on: date)
                                }
                            }
                        } else {
                            Image(systemName: "square.fill")
                                .frame(width: 35)
                                .opacity(0)
                        }
                    }
                }
            }
        }
    }
    
    func statusImage(for date: Date) -> some View {
        let status = task.getStatus(for: date)
        return Image(systemName: status.icon(for: date))
            .foregroundStyle(status.color(forBackground: task.colorOption, on: date))
    }
}

#Preview {
    let task = TaskerTask(name: "Task", colorOption: .navy)
    return VStack {
        CalendarView(task: task)
        Spacer()
    }
    .background(task.colorOption.color)
    .foregroundStyle(task.colorOption.contrastingFontColor)
}
