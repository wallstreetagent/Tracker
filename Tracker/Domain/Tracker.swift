//
//  Tracker.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import Foundation

public struct Tracker: Codable, Hashable {
    public let id: UUID
    public let name: String
    
    public let colorHex: String
    public let emoji: String
  
    public let schedule: Set<Weekday>

    public init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        emoji: String,
        schedule: Set<Weekday>
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.emoji = emoji
        self.schedule = schedule
    }
}
