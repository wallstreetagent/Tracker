//
//  TrackersStorage.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import Foundation
import UIKit

extension TrackersViewController {

    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
        var newCategories: [TrackerCategory] = []
        var inserted = false

        for cat in categories {
            if cat.title == title {
                let updated = TrackerCategory(title: cat.title, trackers: cat.trackers + [tracker])
                newCategories.append(updated)
                inserted = true
            } else {
                newCategories.append(cat)
            }
        }

        if !inserted {
            newCategories.append(TrackerCategory(title: title, trackers: [tracker]))
        }

        categories = newCategories
    }

    func updateTracker(_ updatedTracker: Tracker) {
        categories = categories.map { cat in
            let updatedList = cat.trackers.map { $0.id == updatedTracker.id ? updatedTracker : $0 }
            return TrackerCategory(title: cat.title, trackers: updatedList)
        }
    }

    func deleteTracker(withId id: UUID) {
        categories = categories.map { cat in
            let filtered = cat.trackers.filter { $0.id != id }
            return TrackerCategory(title: cat.title, trackers: filtered)
        }
        completedTrackers = completedTrackers.filter { $0.trackerId != id }
    }

    func markCompleted(trackerId: UUID, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        let exists = completedTrackers.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: day) }
        guard !exists else { return }
        completedTrackers = completedTrackers + [TrackerRecord(trackerId: trackerId, date: day)]
    }

    func unmarkCompleted(trackerId: UUID, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        completedTrackers = completedTrackers.filter { !($0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: day)) }
    }

    func isCompleted(trackerId: UUID, on date: Date) -> Bool {
        let day = Calendar.current.startOfDay(for: date)
        return completedTrackers.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: day) }
    }
}
