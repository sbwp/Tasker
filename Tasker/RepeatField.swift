//
//  RepeatField.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/21/24.
//

import SwiftUI

struct RepeatField: View {
    @Binding var repeatConfig: RepeatConfig
    
    var body: some View {
        VStack {
            HStack {
                Text("Summary:")
                Text(repeatConfig.description)
                Spacer()
            }
            HStack {
                Text("Repeat Every")
                IntegerField("Frequency", value: $repeatConfig.frequency)
                    .frame(width: 100)
                Picker("Unit", selection: $repeatConfig.unit) {
                    ForEach(RepeatUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue)
                    }
                }
                Spacer()
            }
            switch(repeatConfig.unit) {
            case .days:
                EmptyView()
            case .weeks:
                HStack {
                    Text("on")
                    Picker("Weekday", selection: $repeatConfig.dayOfWeek) {
                        ForEach(DayOfWeek.allCases, id: \.self) { weekday in
                            Text(weekday.description)
                        }
                    }
                    Spacer()
                }
            case .months, .years:
                Picker("Time In Month Type", selection: $repeatConfig.timeInMonthType) {
                    ForEach(TimeInMonthType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                HStack {
                    Text("on the")
                    IntegerField("Day", value: $repeatConfig.dayOfMonth)
                        .frame(width: 100)
                    Text(repeatConfig.dayOfMonth?.ordinalSuffix ?? "")
                    Text(repeatConfig.fromEnd ? "to last" : "")
                    
                    switch(repeatConfig.timeInMonthType) {
                    case .dayOfMonth:
                        Text("day")
                    case .nthWeekday:
                        Picker("Weekday", selection: $repeatConfig.dayOfWeek) {
                            ForEach(DayOfWeek.allCases, id: \.self) { weekday in
                                Text(weekday.description)
                            }
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    if (repeatConfig.unit == .years) {
                        Text("of")
                        Picker("Month", selection: $repeatConfig.monthOfYear) {
                            ForEach(MonthOfYear.allCases, id: \.self) { month in
                                Text(month.description)
                            }
                        }
                    } else {
                        Text("of the month")
                    }
                    Spacer()
                }
                
                Toggle("Count From End of Month", isOn: $repeatConfig.fromEnd)
                    .tint(.green)
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var repeatConfig: RepeatConfig = .forPreview
        
        var body: some View {
            RepeatField(repeatConfig: $repeatConfig)
        }
    }
    
    return Preview()
}
