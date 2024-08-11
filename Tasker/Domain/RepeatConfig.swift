//
//  RepeatConfig.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import Foundation

struct RepeatConfig: Codable {
    var unit: RepeatUnit
    var frequency: Int
    var startDate: Date
    var endDate: Date? // Primarily used to keep historical data when stopping doing a task, but can be used to set an end date in advance
    var dayOfWeek: DayOfWeek // Unused for daily, repeat on this day of the week for weekly, monthly (e.g. 3rd Sunday), and annually (e.g. 2nd Monday of May)
    var dayOfMonth: Int? // Unused for daily and weekly, used alone (e.g. May 3rd) or in combination with dayOfWeek (e.g. 3rd Monday) for monthly and annually
    var monthOfYear: MonthOfYear // Unused for daily, weekly, monthly, used for annually to say which Month to repeat in
    // var irregularityOffset: Int // When frequency > 1, makes it quicker to check if this occurs on a given day
    var fromEnd: Bool
    var timeInMonthType: TimeInMonthType
    
    var irregularityOffset: Int {
        startDate.noon.getOffset(in: unit, mod: frequency)
    }
    
    var usesWeekday: Bool {
        unit == .weeks || (unit != .days && timeInMonthType == .nthWeekday)
    }
    
    static var forPreview: RepeatConfig {
        return RepeatConfig(unit: .days, frequency: 1, startDate: Date.practicallyNow)
    }
    
    var description: String {
        let s = frequency > 1 ? "s" : ""
        let unitRepresentation = unit == .weeks
            ? dayOfWeek.description
            : "\(unit.singular)\(s)"
        
        let frequencyStr = unit == .weeks
            ? frequency > 1 ? "\(frequency.formattedAsOrdinal!) " : ""
            : frequency > 1 ? "\(frequency) " : ""
        
        let start = "Every \(frequencyStr)\(unitRepresentation)"
        
        if unit <= .weeks {
            return start
        }
        
        guard let dayOfMonth = dayOfMonth, let dayOfMonthStr = dayOfMonth.formattedAsOrdinal else {
            return "Invalid Configuration"
        }
        
        let ordinalStr = fromEnd
            ? dayOfMonth > 1 ? "\(dayOfMonthStr) to last " : "last "
            : "\(dayOfMonthStr) "
        
        var end = ""
        if unit == .years || fromEnd || usesWeekday {
            let daySignifier = usesWeekday
                ? dayOfWeek.description
                : "day"
            
            let monthText = unit == .years
                ? monthOfYear.description
                : "the month"
            
            end = "\(daySignifier) of \(monthText)"
        }
        return "\(start) on the \(ordinalStr)\(end)"
    }
    
    init(unit: RepeatUnit, frequency: Int, startDate: Date, endDate: Date? = nil, dayOfWeek: DayOfWeek? = nil, dayOfMonth: Int? = nil, monthOfYear: MonthOfYear? = nil, fromEnd: Bool = false, timeInMonthType: TimeInMonthType = .dayOfMonth) {
        self.unit = unit
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.dayOfWeek = dayOfWeek ?? (unit == .weeks ? startDate.dayOfWeekEnum : .monday)
        self.dayOfMonth = dayOfMonth ?? (unit == .months ? (dayOfWeek == nil ? startDate.dayOfMonth : startDate.countOfWeekDayInMonth) : nil)
        self.monthOfYear = monthOfYear ?? (unit == .years ? MonthOfYear(rawValue: startDate.month)! : .january)
        // self.irregularityOffset = startDate.getOffset(in: unit, mod: frequency)
        self.fromEnd = fromEnd
        self.timeInMonthType = timeInMonthType
    }
    
    func occursOn(_ date: Date) -> Bool {
        if date.noon < startDate.noon || (endDate != nil && date.noon > endDate!.noon) || date.noon.getOffset(in: unit, mod: frequency) != irregularityOffset {
            return false
        }
        
        switch unit {
        case .days:
            return true
        case .weeks:
            return date.dayOfWeekEnum == dayOfWeek
        case .years:
            if date.month != monthOfYear.rawValue {
                return false
            }
            fallthrough
        case .months:
            if timeInMonthType == .nthWeekday {
                let countOfWeekDay = fromEnd ? date.reverseCountOfWeekDayInMonth : date.countOfWeekDayInMonth
                return date.dayOfWeekEnum == dayOfWeek && countOfWeekDay == dayOfMonth
            } else {
                let day = fromEnd ? date.reverseDayInMonth : date.dayOfMonth
                return day == dayOfMonth
            }
        }
    }
    
    func nextOccurrence(from date: Date) -> Date {
        var current = date.noon
        
        if description == "Invalid Configuration" {
            return .distantFuture
        }
        
        while !occursOn(current) {
            if abs(current.distanceFrom(date, in: [.year]).year ?? 11) > 10 {
                return .distantFuture
            }
            
            switch unit {
            case .days, .months:
                current = current.addDays(1)
            case .weeks:
                current = current.next(dayOfWeek)
            case .years:
                var changeMade = false
                while frequency != 1 && current.getOffset(in: unit, mod: frequency) != irregularityOffset {
                    current = current.lastDayOfYear.addDays(1)
                    changeMade = true
                }
                while current.month != monthOfYear.rawValue {
                    current = current.firstDayOfMonth.addMonths(1)
                    changeMade = true
                }
                if !changeMade {
                    current = current.addDays(1)
                }
            }
        }
        
        return current
    }
}
