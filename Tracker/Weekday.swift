//
//  Weekday.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import Foundation

public enum Weekday: Int, CaseIterable, Codable, Hashable {
    case mon = 1, tue, wed, thu, fri, sat, sun

    // MARK: 


    public static func fromCalendar(_ value: Int) -> Weekday {
        switch value {
        case 1: return .sun
        case 2: return .mon
        case 3: return .tue
        case 4: return .wed
        case 5: return .thu
        case 6: return .fri
        case 7: return .sat
        default: return .mon
        }
    }


    public var toCalendarValue: Int {
        switch self {
        case .sun: return 1
        case .mon: return 2
        case .tue: return 3
        case .wed: return 4
        case .thu: return 5
        case .fri: return 6
        case .sat: return 7
        }
    }
}

public extension Weekday {
    static var workdays: Set<Weekday> { [.mon, .tue, .wed, .thu, .fri] }
    static var weekend: Set<Weekday> { [.sat, .sun] }
    static var everyday: Set<Weekday> { Set(Weekday.allCases) }
}
