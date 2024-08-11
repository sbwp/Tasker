//
//  MonthOfYear.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/17/24.
//

import Foundation

enum MonthOfYear: Int, Codable, CaseIterable {
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
    
    static let descriptions = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var description: String {
        return MonthOfYear.descriptions[rawValue]
    }
}
