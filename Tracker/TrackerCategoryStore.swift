//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import CoreData

protocol TrackerCategoryStoring {
    func ensureCategory(title: String, in ctx: NSManagedObjectContext) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryStore: TrackerCategoryStoring {
    private let stack: CoreDataStack
    init(stack: CoreDataStack) { self.stack = stack }

    func ensureCategory(title: String, in ctx: NSManagedObjectContext) throws -> TrackerCategoryCoreData {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", title)
        req.fetchLimit = 1
        if let found = try ctx.fetch(req).first { return found }

        let obj = TrackerCategoryCoreData(context: ctx)
        obj.id = UUID()
        obj.title = title
        return obj
    }
}
