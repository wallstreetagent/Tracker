//
//  mockfile.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/1/25.
//

import Foundation
@testable import Tracker

final class StubTrackersProvider: TrackersProvider {
    var onChange: (() -> Void)?

    func snapshot(for date: Date, query: String?) throws -> [TrackerCategory] {
        let t1 = Tracker(id: UUID(), name: "Поливать растения", colorHex: "#34C759", emoji: "🌿", schedule: [])
        let t2 = Tracker(id: UUID(), name: "Свеча вечером", colorHex: "#5856D6", emoji: "🕯", schedule: [])
        let home = TrackerCategory(title: "Дом", trackers: [t1, t2])
        let q = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [home] }
        let filtered = home.trackers.filter { $0.name.lowercased().contains(q) }
        return filtered.isEmpty ? [] : [TrackerCategory(title: home.title, trackers: filtered)]
    }

    func createTracker(_ tracker: Tracker, in categoryTitle: String) throws {}
    func updateTracker(id: UUID, name: String, schedule: Set<Weekday>, colorHex: String, emoji: String, categoryTitle: String) throws {}
    func deleteTracker(id: UUID) throws {}
    func togglePin(id: UUID) throws {}
    func toggleRecord(trackerId: UUID, on date: Date) throws {}
    func totalDays(for trackerId: UUID) throws -> Int { 3 }
    func isDone(trackerId: UUID, on date: Date) throws -> Bool { false }
}
