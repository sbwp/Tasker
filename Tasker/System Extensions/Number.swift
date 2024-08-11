//
//  Number.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/20/24.
//

import Foundation

protocol Numeric: Comparable {
    var asNSNumber: NSNumber { get }
}

extension Numeric {
    var formattedAsOrdinal: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: self.asNSNumber)
    }
    
    var ordinalSuffix: String? {
        return formattedAsOrdinal?.replacing(try! Regex("[0-9]*"), with: "")
    }
    
    func clampBetween(_ min: Self, and max: Self) -> Self {
        return self < min ? min : (self > max ? max : self)
    }
    
    func clampToMin(_ min: Self) -> Self {
        return self < min ? min : self
    }
    
    func clampToMax(_ max: Self) -> Self {
        return self > max ? max : self
    }
}

extension Int: Numeric {
    var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Double: Numeric {
    var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Float: Numeric {
    var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

