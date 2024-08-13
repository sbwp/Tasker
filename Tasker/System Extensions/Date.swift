//
//  Date.swift
//  Tasker
//
//  Created by Sabrina Bea on 2/29/20.
//  Copyright ©2020 Sabrina Bea. All rights reserved.
//

import Foundation

// MARK: Get details
extension Date {
    static var now: Date {
        Date()
    }
    
    static var practicallyNow: Date {
        return now.hour < 4 ? now.yesterday.endOfDay : now
    }
    
    var endOfDay: Date {
        return Date.from(year: self.year, month: self.month, day: self.dayOfMonth, hour: 23, minute: 59, second: 59)!
    }
    
    var dayOfWeekEnum: DayOfWeek {
        DayOfWeek(rawValue: dayOfWeek)!
    }
    
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var normalizedDayOfWeekNumber: Int {
        let n = dayOfWeek - Calendar.current.firstWeekday + 1
        return n < 1 ? n + 7 : n
    }
    
    var weekDayName: String {
        DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: self) - 1]
    }
    
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }
    
    // Month as a one-indexed integer
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        Calendar.current.component(.second, from: self)
    }
    
    var nanosecond: Int {
        Calendar.current.component(.nanosecond, from: self)
    }
    
    var weekOfYear: Int {
        var calendar = Calendar.current
        calendar.minimumDaysInFirstWeek = 1
        return calendar.component(.weekOfYear, from: self)
    }
    
    var weekOfMonth: Int {
        var calendar = Calendar.current
        calendar.minimumDaysInFirstWeek = 1
        return calendar.component(.weekOfMonth, from: self)
    }
    
    var numberOfDaysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)!.count
    }
    
    private var monthIndex: Int {
        month - 1
    }
}

// MARK: Repeating Event Matchers
extension Date {
    var isWeekend: Bool {
        isA(.sunday) || isA(.saturday)
    }
    
    var isWeekday: Bool {
        !isWeekend
    }
    
    func isA(_ weekday: DayOfWeek) -> Bool {
        this(weekday) == self
    }
    
    func isSameDay(as date: Date) -> Bool {
        noon == date.noon
    }
    
    func isSameDayOfWeek(as date: Date) -> Bool {
        date.isA(self.dayOfWeekEnum)
    }
    
    func isInSameWeek(as date: Date) -> Bool {
        this(Date.firstDayOfWeek).isSameDay(as: date.this(Date.firstDayOfWeek))
    }
    
    func isInSameMonth(as date: Date) -> Bool {
        year == date.year && month == date.month
    }
    
    func isInSameYear(as date: Date) -> Bool {
        year == date.year
    }
    
    func coincidesBiweekly(with date: Date) -> Bool {
        if (!isSameDayOfWeek(as: date)) {
            return false
        }
        
        let distance = distanceFrom(date, in: [.day]).day ?? 1
        return distance % 14 == 0
    }
    
    // Note: Semimonthly, Monthly, and Bimonthly cannot exist with dates above 28 (or 14/15 for semi).
    func coincidesSemimonthly(with date: Date) -> Bool {
        self.dayOfMonth % 15 == date.dayOfMonth % 15
    }
    
    // Note: Semimonthly, Monthly, and Bimonthly cannot exist with dates above 28 (or 14/15 for semi).
    func sameDayOfMonth(as date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth
    }
    
    // Note: Semimonthly, Monthly, and Bimonthly cannot exist with dates above 28 (or 14/15 for semi).
    func coincidesBimonthly(with date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth && self.month % 2 == date.month % 2
    }
    
    // Note Quarterly and Semiannually cannot exist with dates of 31 or above 28 if they occur in February.
    func coincidesQuarterly(with date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth && self.month % 3 == date.month % 3
    }
    
    // Note Quarterly and Semiannually cannot exist with dates of 31 or above 28 if they occur in February.
    func coincidesSemiannually(with date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth && self.month % 6 == date.month % 6
    }
    
    func sameDayOfYear(as date: Date) -> Bool {
        let myComponents = Calendar.current.dateComponents([.day, .month], from: self)
        let otherComponents = Calendar.current.dateComponents([.day, .month], from: date)
        
        return myComponents.day == otherComponents.day && myComponents.month == otherComponents.month
    }
}

// MARK: Get Related Dates
// Note: Calendar.current.date(bySetting: .month, value: 1, of: date) means January (months 1-12, not 0-11)
extension Date {
    static var monthArrays = [Int: [[Date?]]]()
    
    static func get2DArray(of month: Int, in year: Int) -> [[Date?]] {
        let hashLookup = year * 100 + month
        if let existingValue = monthArrays[hashLookup] {
            return existingValue
        }
        
        var days = [Date]()
        days.reserveCapacity(31)
        let first = Date.from(year: year, month: month, day: 1)!
        var current = first
        
        while (current.month == month) {
            days.append(current)
            current = current.tomorrow
        }
        
        let last = current.yesterday
        let numWeeks = last.weekOfMonth
        
        var weeks = [[Date?]]()
        weeks.reserveCapacity(numWeeks)
        var weekNo = 1
        var week = [Date?]()
        week.reserveCapacity(7)
        
        for _ in 1..<first.normalizedDayOfWeekNumber {
            week.append(nil)
        }
        
        for day in days {
            if day.weekOfMonth != weekNo {
                weekNo += 1
                weeks.append(week)
                week = [Date?]()
                week.reserveCapacity(7)
            }
            week.append(day)
        }
        
        for _ in last.normalizedDayOfWeekNumber..<7 {
            week.append(nil)
        }
        weeks.append(week)
        
        monthArrays[hashLookup] = weeks
        return weeks
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var noon: Date {
        startOfDay.add(12, .hour)
    }
    
    var tomorrow: Date {
        addDays(1)
    }
    
    var yesterday: Date {
        addDays(-1)
    }
    
    var firstDayOfMonth: Date {
        if Calendar.current.component(.day, from: self) == 1 {
            return self
        }
        return Calendar.current.date(bySetting: .day, value: 1, of: self)!.addMonths(-1)
    }
    
    var lastDayOfYear: Date {
        let december = Calendar.current.date(bySetting: .month, value: 12, of: self)!
        return Calendar.current.date(bySetting: .day, value: 31, of: december)!
    }
    
    // This isn't very pretty
    func nextOccurrenceOfDayOfMonth(_ day: Int, includeSelf: Bool = false) -> Date? {
        let thisMonthDate = Calendar.current.date(bySetting: .day, value: day, of: self)
        if let thisMonthDate = thisMonthDate, dayOfMonth > day || !includeSelf && dayOfMonth == day {
            if month == 12 {
                guard let partial = Calendar.current.date(bySetting: .year, value: year + 1, of: thisMonthDate) else {
                    return nil
                }
                return Calendar.current.date(bySetting: .month, value: 1, of: partial)
            } else {
                return Calendar.current.date(bySetting: .month, value: month + 1, of: thisMonthDate)
            }
        } else {
            return thisMonthDate
        }
    }
    
    func nextAnniversary(of date: Date, includeSelf: Bool = false) -> Date? {
        let thisYearDate = Date.from(year: self.year, month: date.month, day: date.dayOfMonth)
        if let thisYearDate = thisYearDate, self > date || !includeSelf && self == date {
            return Calendar.current.date(bySetting: .year, value: year + 1, of: thisYearDate)
        } else {
            return thisYearDate
        }
    }
    
    func addDays(_ days: Int) -> Date  {
        add(days, .day)
    }
    
    func addMonths(_ months: Int) -> Date  {
        add(months, .month)
    }
    
    func addYears(_ years: Int) -> Date  {
        add(years, .year)
    }
    
    func add(_ value: Int, _ unit: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: unit, value: value, to: self)!
    }
    
    func weekOf() -> [Date] {
        let start = this(Date.firstDayOfWeek)
        return [0, 1, 2, 3, 4, 5, 6].map { number in
            start.addDays(number)
        }
    }
    
    func this(dayOfMonth: Int) -> Date {
        let first = Calendar.current.date(bySetting: .day, value: 1, of: self)!.addMonths(-1)
        if dayOfMonth == 1 {
            return first
        }
        return Calendar.current.date(bySetting: .day, value: dayOfMonth, of: first)!
    }
    
    func this(_ weekday: DayOfWeek) -> Date {
        previous(Date.firstDayOfWeek, considerToday: true).next(weekday, considerToday: true)
    }
    
    func next(_ weekday: DayOfWeek, considerToday: Bool = false) -> Date {
        get(.next,
            weekday,
            considerToday: considerToday)
    }
    
    func previous(_ weekday: DayOfWeek, considerToday: Bool = false) -> Date {
        get(.previous,
            weekday,
            considerToday: considerToday)
    }
    
    func nextWeekendDay(considerToday: Bool = false) -> Date {
        let saturday = next(.saturday, considerToday: considerToday)
        let sunday = next(.sunday, considerToday: considerToday)
        return saturday < sunday ? saturday : sunday
    }
    
    func nextWeekday(considerToday: Bool = false) -> Date {
        let nextDay = considerToday ? self : tomorrow
        let nextDayOfWeek = nextDay.dayOfWeekEnum // Avoid recomputing for checking saturday and sunday
        
        return nextDayOfWeek == .saturday || nextDayOfWeek == .sunday ? nextDay.next(.monday) : nextDay
    }
    
    func component(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
    
    func lessThanByTimeOnly(_ other: Date) -> Bool {
        let componentsToCheck: [Calendar.Component] = [.hour, .minute, .second, .nanosecond]
        for c in componentsToCheck {
            if component(c) < other.component(c) {
                return true
            }
            if component(c) > other.component(c) {
                return false
            }
        }
        return false
    }
    
    func greaterThanByTimeOnly(_ other: Date) -> Bool {
        return other.lessThanByTimeOnly(self)
    }
    
    func equalByTimeOnly(_ other: Date) -> Bool {
        return !lessThanByTimeOnly(other) && !other.lessThanByTimeOnly(self)
    }
}

// MARK: Distance
extension Date {
    static func daysBetween(_ start: Date, and end: Date) -> Int {
        distanceBetween(start, and: end, in: [.day]).day!
    }
    
    // Number of weeks between start and end, not including the week of start or the week of end
    static func fullWeeksBetween(_ start: Date, and end: Date) -> Int {
        distanceBetween(start.this(.monday).next(.monday), and: end.this(.monday), in: [.weekOfYear]).weekOfYear!
    }
    
    // Number of months between start and end, not including the month of start or the month of end
    static func fullMonthsBetween(_ start: Date, and end: Date) -> Int {
        distanceBetween(start.firstDayOfMonth.addMonths(1), and: end.firstDayOfMonth, in: [.month]).month!
    }
    
    // Number of years between start and end, not including the year of start or the year of end
    static func fullYearsBetween(_ start: Date, and end: Date) -> Int {
        end.year - start.year - 1
    }
    
    static func distanceBetween(_ start: Date, and end: Date, in components: Set<Calendar.Component> = [.day]) -> DateComponents {
        start.distanceFrom(end, in: components)
    }
    
    func distanceFrom(_ date: Date, in components: Set<Calendar.Component> = [.day]) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents(components, from: self.noon, to: date.noon)
    }
    
    static var epoch = Date(timeIntervalSinceReferenceDate: 0)
}

// MARK: Weekday Helpers
extension Date {
    static var firstDayOfWeek: DayOfWeek = .monday
    
    private func get(_ direction: SearchDirection, _ weekDay: DayOfWeek, considerToday consider: Bool = false) -> Date {
        let searchWeekdayIndex = weekDay.rawValue
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex
        
        return calendar.nextDate(after: self, matching: nextDateComponent, matchingPolicy: .nextTime, direction: direction.calendarSearchDirection)!
    }
    
    enum SearchDirection {
        case next
        case previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }
}

// MARK: Recurrence Helpers
extension Date {
    var isDistantFuture: Bool {
        return year == Date.distantFuture.year
    }
    
    var isProblematicForSemimonthly: Bool {
        (dayOfMonth >= 14 && dayOfMonth <= 16) || dayOfMonth > 28
    }
    
    var isProblematicForMonthly: Bool {
        dayOfMonth > 28
    }
    
    var isProblematicForBimonthly: Bool {
        dayOfMonth > 30 || monthIndex % 2 == 1 && dayOfMonth > 28
    }
    
    var isProblematicForQuarterly: Bool {
        dayOfMonth > 30 || monthIndex % 3 == 1 && dayOfMonth > 28
    }
    
    var isProblematicForSemiannually: Bool {
        monthIndex % 6 != 0 && dayOfMonth > 30 || monthIndex % 6 == 1 && dayOfMonth > 28
    }
    
    var isProblematicForAnnually: Bool {
        monthIndex == 1 && dayOfMonth == 29
    }
    
    var isTodayOrFuture: Bool {
        return self > Date.practicallyNow || isToday
    }
    
    var isTodayOrPast: Bool {
        return self < Date.practicallyNow || isToday
    }
    
    var isToday: Bool {
        return self.isSameDay(as: Date.practicallyNow)
    }
    
    var isFutureAndNotToday: Bool {
        return self > Date.practicallyNow && !isToday
    }
    
    var isPastAndNotToday: Bool {
        return self < Date.practicallyNow && !isToday
    }
    
    func isProblematic(for repeatFrequency: RepeatFrequency) -> Bool {
        switch repeatFrequency {
        case .semimonthly:
            return isProblematicForSemimonthly
        case .monthly:
            return isProblematicForMonthly
        case .bimonthly:
            return isProblematicForBimonthly
        case .quarterly:
            return isProblematicForQuarterly
        case .semiannually:
            return isProblematicForSemiannually
        case .annually:
            return isProblematicForAnnually
        default:
            return false
        }
    }
    
    // Note: This is only for use in calculating next occurence of a problematic date, so it is assumed that the date being passed in is problematic (ex: see annually)
    func nextOccurenceOf(_ repeatFrequency: RepeatFrequency) -> Date {
        switch repeatFrequency {
            case .semimonthly:
                return addDays(15)
            case .monthly:
                return addMonths(1)
            case .bimonthly:
                return addMonths(2)
            case .quarterly:
                return addMonths(3)
            case .semiannually:
                return addMonths(3)
            case .annually:
                // Returns February 28th of the next year
                var dateComponents = Calendar.current.dateComponents([.year], from: self)
                dateComponents.year = dateComponents.year! + 1
                dateComponents.month = 2
                dateComponents.day = 28
                return Calendar.current.date(from: dateComponents)!
            default:
                assertionFailure("nextOccurenceOf called with unimplemented repeatFrequency")
                return tomorrow
        }
    }
}

// MARK: Quick Formatting
extension Date {
    enum DateComponentLength {
        case none
        case short
        case long
        case full
        case variable
    }
    
    func formatted(fromTemplate template: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        
        return formatter.string(from: self)
    }
    
    func formatted(year: DateComponentLength = .short, month: DateComponentLength = .short, day: DateComponentLength = .short, weekday: DateComponentLength = .none) -> String {
        if (isDistantFuture) {
            return "Never"
        }
        
        var yearLength = year
        if year == .variable {
            yearLength = .none
            let thisYear = Date.practicallyNow.year
            if (self.year != thisYear) {
                yearLength = self.year / 100 == thisYear / 100 ? .short : .long
            }
        }
        
        let weekTemplate = weekday == .none ? "" : weekday == .short ? "EEE" : "EEEE"
        let dayTemplate = day == .long ? "dd" : day == .none ? "" : "d"
        let monthTemplate = month == .full ? "MMMM" : month == .long ? "MM" : month == .short ? "M" : ""
        let yearTemplate = yearLength == .none ? "" : yearLength == .short ? "yy" : "yyyy"
        return formatted(fromTemplate: weekTemplate + dayTemplate + monthTemplate + yearTemplate)
    }
    
    var formattedAsTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}

// MARK: Quick Initialization
extension Date {
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return Calendar.current.date(from: components)
    }
}

// MARK: Problematic Recurrences
extension Date {
    // Returns (one-off dates, safe recurrence start)
    func resolveProblems(for repeatFrequency: RepeatFrequency) -> ([Date], Date) {
        var currentDate = self
        var oneOffs: [Date] = []
        while currentDate.isProblematic(for: repeatFrequency) {
            oneOffs.append(currentDate)
            currentDate = currentDate.nextOccurenceOf(repeatFrequency)
        }
        return (oneOffs, currentDate)
    }
}

// MARK: Repeat Irreguarity Helpers
extension Date {
    // e.g. given the 4th Tuesday in May, return 4
    var countOfWeekDayInMonth: Int {
        return (self.dayOfMonth + 6) / 7
    }
    
    var reverseCountOfWeekDayInMonth: Int {
        return (self.reverseDayInMonth + 6) / 7
    }
    
    // e.g. on July 31 returns 1, on July 30 returns 2, on July 29 returns 3, etc
    var reverseDayInMonth: Int {
        return self.addMonths(1).firstDayOfMonth.addDays(-1).dayOfMonth - (self.dayOfMonth - 1)
    }
    
    func getOffset(in unit: RepeatUnit, mod base: Int) -> Int {
        if base <= 1 {
            return 0
        }
        
        let dateComponent: Calendar.Component = switch unit {
        case .days: .day
        case .weeks: .weekOfYear
        case .months: .month
        case .years: .year
        }
        
        return Calendar.current.dateComponents([dateComponent], from: Date.epoch, to: self).value(for: dateComponent)! % base
    }
}
