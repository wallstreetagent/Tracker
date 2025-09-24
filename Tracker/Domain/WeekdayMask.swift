//
//  WeekdayMask.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import Foundation

enum WeekdayMask {
    /// Битовая маска: Пн=бит0 … Вс=бит6
    static func make(from set: Set<Weekday>) -> UInt16 {
        set.reduce(0) { acc, d in
            let bit: Int
            switch d {
            case .mon: bit = 0
            case .tue: bit = 1
            case .wed: bit = 2
            case .thu: bit = 3
            case .fri: bit = 4
            case .sat: bit = 5
            case .sun: bit = 6
            }
            return acc | (1 << bit)
        }
    }

    static func toSet(_ mask: UInt16) -> Set<Weekday> {
        var s = Set<Weekday>()
        if (mask & (1<<0)) != 0 { s.insert(.mon) }
        if (mask & (1<<1)) != 0 { s.insert(.tue) }
        if (mask & (1<<2)) != 0 { s.insert(.wed) }
        if (mask & (1<<3)) != 0 { s.insert(.thu) }
        if (mask & (1<<4)) != 0 { s.insert(.fri) }
        if (mask & (1<<5)) != 0 { s.insert(.sat) }
        if (mask & (1<<6)) != 0 { s.insert(.sun) }
        return s
    }
}
