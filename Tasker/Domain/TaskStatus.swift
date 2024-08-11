// ©2024 Sabrina Bea. All rights reserved.

import Foundation
import SwiftUI

enum TaskStatus {
    case unscheduled
    case scheduled
    case missed
    case skipped
    case delayed
    case completed
    case overdue
    
    func color(forBackground option: ColorOption, on date: Date) -> Color {
        switch self {
        case .unscheduled:
            option.inactiveColor
        case .scheduled:
            date.isToday ? option.needsAttentionColor : option.infoColor
        case .missed:
            option.errorColor
        case .skipped:
            option.inactiveColor
        case .delayed:
            option.needsAttentionColor
        case .completed:
            option.successColor
        case .overdue:
            date.isToday ? option.needsAttentionColor : option.warnColor
        }
    }
    
    func icon(for date: Date) -> String {
        switch self {
        case .unscheduled:
            "square.fill"
        case .scheduled:
            date.isToday ? "checkmark.square" : "bell.square.fill"
        case .delayed, .missed:
            "xmark.square.fill"
        case .skipped:
            "hand.raised.square"
        case .completed:
            "checkmark.square.fill"
        case .overdue:
            date.isToday ? "exclamationmark.octagon" : "xmark.square"
        }
    }
}
