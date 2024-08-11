//
//  RepeatUnit.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import Foundation

enum RepeatUnit: String, Codable, CaseIterable, Comparable {
    static func < (lhs: RepeatUnit, rhs: RepeatUnit) -> Bool {
        switch rhs {
        case .days:
            return false
        case .weeks:
            return lhs == .days
        case .months:
            return lhs == .days || rhs == .months
        case .years:
            return lhs != .years
        }
    }
    
    case days
    case weeks
    case months
    case years
    
    var singular: String {
        return rawValue.replacingOccurrences(of: "s", with: "")
    }
}
