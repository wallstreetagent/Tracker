//
//  TrackersProvider.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import Foundation

protocol TrackersProvider: AnyObject {
    var onChange: (() -> Void)? { get set }

    func snapshot(for date: Date, query: String?) throws -> [TrackerCategory]
    func createTracker(_ tracker: Tracker, in categoryTitle: String) throws
    func toggleRecord(trackerId: UUID, on date: Date) throws
    func totalDays(for trackerId: UUID) throws -> Int
    func isDone(trackerId: UUID, on date: Date) throws -> Bool
}
