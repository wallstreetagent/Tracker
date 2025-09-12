//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import CoreData

protocol TrackerRecordStoring {
    func toggle(trackerId: UUID, on date: Date) throws
    func totalDays(for trackerId: UUID) throws -> Int
    func isDone(trackerId: UUID, on date: Date) throws -> Bool
}

final class TrackerRecordStore: TrackerRecordStoring {
    private let stack: CoreDataStack
    init(stack: CoreDataStack) { self.stack = stack }

    private func day(_ date: Date) -> Date { Calendar.current.startOfDay(for: date) }

    func toggle(trackerId: UUID, on date: Date) throws {
        let d = day(date)
        stack.performBackgroundTask { ctx in
            let tReq: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            tReq.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
            tReq.fetchLimit = 1
            guard let tracker = try ctx.fetch(tReq).first else { return }

            let rReq: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            rReq.predicate = NSPredicate(format: "tracker == %@ AND date == %@", tracker, d as NSDate)
            rReq.fetchLimit = 1

            if let rec = try ctx.fetch(rReq).first {
                ctx.delete(rec)
            } else {
                let rec = TrackerRecordCoreData(context: ctx)
                rec.id = UUID()
                rec.date = d
                rec.tracker = tracker
            }
        }
    }

    func totalDays(for trackerId: UUID) throws -> Int {
        let req: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        req.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        req.resultType = .countResultType
        let res = try stack.viewContext.fetch(req)
        return res.first?.intValue ?? 0
    }

    func isDone(trackerId: UUID, on date: Date) throws -> Bool {
        let d = day(date)
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "tracker.id == %@ AND date == %@", trackerId as CVarArg, d as NSDate)
        req.fetchLimit = 1
        return try stack.viewContext.fetch(req).first != nil
    }
}
