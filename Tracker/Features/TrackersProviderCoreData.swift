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
    private let categoryStore: TrackerCategoryStoring

    var onChange: (() -> Void)?

    init(stack: CoreDataStack) {
        let catStore = TrackerCategoryStore(stack: stack)
        let trStore = TrackerStore(stack: stack, categoryStore: catStore)
        let recStore = TrackerRecordStore(stack: stack)

        self.categoryStore = catStore
        self.trackerStore = trStore
        self.recordStore = recStore

        // Любые изменения в Core Data (категории/трекеры/записи) → один колбэк наружу
        trStore.onChange = { [weak self] in self?.onChange?() }
        catStore.onChange = { [weak self] in self?.onChange?() }
        recStore.onChange = { [weak self] in self?.onChange?() }
    }

    func snapshot(for date: Date, query: String?) throws -> [TrackerCategory] {
        let items = try trackerStore.snapshot()

        let calWeekday = Calendar.current.component(.weekday, from: date)
        let weekday = Weekday.fromCalendar(calWeekday)
        let q = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filtered = items.filter { pair in
            let t = pair.tracker
            let mask = WeekdayMask.make(from: t.schedule)
            let byDay = mask == 0 || t.schedule.contains(weekday) // нерегулярные трекеры проходят всегда
            let byText = q.isEmpty || t.name.lowercased().contains(q)
            return byDay && byText
        }

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
