//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import CoreData

protocol TrackerCategoryStoring: AnyObject {
    var onChange: (() -> Void)? { get set }
    func ensureCategory(title: String, in ctx: NSManagedObjectContext) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoring {
    private let stack: CoreDataStack
    var onChange: (() -> Void)?

    private lazy var frc: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let c = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: stack.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        c.delegate = self
        try? c.performFetch()
        return c
    }()

    init(stack: CoreDataStack) {
        self.stack = stack
        super.init()
        _ = frc
    }

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

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
