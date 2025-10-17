//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/1/25.
//

import Foundation

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsEvent: String {
    case open  = "open"
    case close = "close"
    case click = "click"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track    = "track"
    case filter   = "filter"
    case edit     = "edit"
    case delete   = "delete"
}

protocol AnalyticsReporting {
    func send(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?)
}

final class AnalyticsService: AnalyticsReporting {
    static let shared = AnalyticsService()
    private init() {}

    func send(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        var params: [String: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item { params["item"] = item.rawValue }

        #if DEBUG
        print("APP_METRICA_LOG => \(params)")
        #endif

        #if canImport(AppMetricaCore)
        AppMetrica.reportEvent("ui_event", parameters: params)
        #elseif canImport(YandexMobileMetrica)
        YMMYandexMetrica.reportEvent("ui_event", parameters: params, onFailure: nil)
        #else
        #endif
    }
}
