//
//  DayOfWeek.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import Foundation

enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    static let descriptions = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var description: String {
        return DayOfWeek.descriptions[rawValue - 1]
    }
}
