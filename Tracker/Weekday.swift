//
//  Weekday.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import Foundation

public enum Weekday: Int, CaseIterable, Codable {
    case mon = 1, tue, wed, thu, fri, sat, sun
}

public extension Weekday {
    static var workdays: Set<Weekday> { [.mon, .tue, .wed, .thu, .fri] }
    static var weekend: Set<Weekday> { [.sat, .sun] }
    static var everyday: Set<Weekday> { Set(Weekday.allCases) }
}
