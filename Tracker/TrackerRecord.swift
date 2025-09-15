//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import Foundation

public struct TrackerRecord: Codable, Hashable {
    public let trackerId: UUID
    public let date: Date

    public init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = Calendar.current.startOfDay(for: date)
    }
}
