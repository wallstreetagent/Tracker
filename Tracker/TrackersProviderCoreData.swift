//
//  TrackersProviderCoreData.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import Foundation

final class TrackersProviderCoreData: TrackersProvider {
    private let trackerStore: TrackerStoring
    private let recordStore: TrackerRecordStoring

    init(stack: CoreDataStack) {
        let catStore = TrackerCategoryStore(stack: stack)
        self.trackerStore = TrackerStore(stack: stack, categoryStore: catStore)
        self.recordStore = TrackerRecordStore(stack: stack)
    }

    func snapshot(for date: Date, query: String?) throws -> [TrackerCategory] {
        let items = try trackerStore.snapshot()

        // Фильтрация по дню и поиску
        let calWeekday = Calendar.current.component(.weekday, from: date)
        let weekday = Weekday.fromCalendar(calWeekday)
        let q = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filtered = items.filter { pair in
            let t = pair.tracker
            let mask = WeekdayMask.make(from: t.schedule)
            let byDay = mask == 0 || t.schedule.contains(weekday) // mask==0 → нерегулярный
            let byText = q.isEmpty || t.name.lowercased().contains(q)
            return byDay && byText
        }

        // Группировка по названию категории
        let grouped = Dictionary(grouping: filtered, by: { $0.categoryTitle })
        return grouped.keys.sorted().map { title in
            let trackers = grouped[title]!.map { $0.tracker }
            return TrackerCategory(title: title, trackers: trackers)
        }
    }

    func createTracker(_ tracker: Tracker, in categoryTitle: String) throws {
        try trackerStore.create(tracker, categoryTitle: categoryTitle)
    }

    func toggleRecord(trackerId: UUID, on date: Date) throws {
        try recordStore.toggle(trackerId: trackerId, on: date)
    }

    func totalDays(for trackerId: UUID) throws -> Int {
        try recordStore.totalDays(for: trackerId)
    }

    func isDone(trackerId: UUID, on date: Date) throws -> Bool {
        try recordStore.isDone(trackerId: trackerId, on: date)
    }
}
