//
//  TrackerStoreCountingCoreData.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/24/25.
//

import CoreData

protocol TrackerCounting: AnyObject {
    func count(in categoryTitle: String) throws -> Int
}

final class TrackerStoreCountingCoreData: TrackerCounting {
    private let stack: CoreDataStack
    init(stack: CoreDataStack) { self.stack = stack }

    func count(in categoryTitle: String) throws -> Int {
        let ctx = stack.viewContext

        let cReq: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        cReq.predicate = NSPredicate(format: "title == %@", categoryTitle)
        cReq.fetchLimit = 1
        guard let category = try ctx.fetch(cReq).first else { return 0 }

        let tReq: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "TrackerCoreData")
        tReq.predicate = NSPredicate(format: "category == %@", category)
        tReq.resultType = .countResultType
        let res = try ctx.fetch(tReq)
        return res.first?.intValue ?? 0
    }
}
