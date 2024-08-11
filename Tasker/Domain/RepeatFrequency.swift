//
//  RepeatFrequency.swift
//  Tasker
//
//  Created by Sabrina Bea on 3/19/20.
//  Copyright © 2020 Sabrina Bea. All rights reserved.
//

import Foundation

// May add more complex system later, but I will hardcode common repeat times for now
public enum RepeatFrequency: String, Codable {
    case never = "Never"
    case weekendsOnly = "Weekends"
    case weekdaysOnly = "Weekdays"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case semimonthly = "Semimonthly"
    case monthly = "Monthly"
    case bimonthly = "Bimonthly"
    case quarterly = "Quarterly"
    case semiannually = "Semiannually"
    case annually = "Annually"
    
    static var everythingButNever: [RepeatFrequency] {
        return [ weekendsOnly, weekdaysOnly, daily, weekly, biweekly, semimonthly, monthly, bimonthly, quarterly, semiannually, annually ]
    }
    
    static var everything: [RepeatFrequency] {
        return [ never ] + everythingButNever
    }
}

extension RepeatFrequency: Comparable {
    public static func <(_ lhs: RepeatFrequency, _ rhs: RepeatFrequency) -> Bool {
        switch lhs {
        case .never:
            return rhs != .never
        case .weekendsOnly:
            return ![.never, .weekendsOnly].contains(rhs)
        case .weekdaysOnly:
            return ![.never, .weekendsOnly, .weekdaysOnly].contains(rhs)
        case .daily:
            return ![.never, .weekendsOnly, .weekdaysOnly, .daily].contains(rhs)
        case .weekly:
            return ![.never, .weekendsOnly, .weekdaysOnly, .daily, .weekly].contains(rhs)
        case .biweekly:
            return [.semimonthly, .monthly, .bimonthly, .quarterly, .semiannually, .annually].contains(rhs)
        case .semimonthly:
            return [.monthly, .bimonthly, .quarterly, .semiannually, .annually].contains(rhs)
        case .monthly:
            return [.bimonthly, .quarterly, .semiannually, .annually].contains(rhs)
        case .bimonthly:
            return [.quarterly, .semiannually, .annually].contains(rhs)
        case .quarterly:
            return [.semiannually, .annually].contains(rhs)
        case .semiannually:
            return rhs == .annually
        case .annually:
            return false
        }
    }
}
