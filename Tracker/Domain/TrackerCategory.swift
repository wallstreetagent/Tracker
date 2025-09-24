//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import Foundation

public struct TrackerCategory: Codable, Hashable {
    public let title: String
    public let trackers: [Tracker]

    public init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
