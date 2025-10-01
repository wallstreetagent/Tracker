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
        case .all:         return "Все трекеры"
        case .today:       return "Трекеры на сегодня"
        case .completed:   return "Завершённые"
        case .uncompleted: return "Не завершённые"
        }
    }

    /// Эти варианты считаются «сбросом» (галочку не показываем и визуально фильтр не активен)
    var isReset: Bool {
        self == .all || self == .today
    }
}
