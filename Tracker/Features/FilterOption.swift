//
//  FilterOption.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/1/25.
//

import Foundation

enum FilterOption: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all:         return NSLocalizedString("filter.all", comment: "")
        case .today:       return NSLocalizedString("filter.today", comment: "")
        case .completed:   return NSLocalizedString("filter.completed", comment: "")
        case .uncompleted: return NSLocalizedString("filter.uncompleted", comment: "")
        }
    }


    var isReset: Bool {
        self == .all || self == .today
    }
}
