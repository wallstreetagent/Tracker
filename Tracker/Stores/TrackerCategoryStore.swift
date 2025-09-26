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
    func fetchAllTitles() throws -> [String]
    func createCategory(title: String) throws
    func rename(from oldTitle: String, to newTitle: String) throws
    func delete(title: String) throws
    func renameCategory(oldTitle: String, newTitle: String) throws
    func deleteCategory(title: String) throws
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

    func fetchAllTitles() throws -> [String] {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return try stack.viewContext.fetch(req).compactMap { $0.title }
    }

    func createCategory(title: String) throws {
        let ctx = stack.viewContext
        _ = try ensureCategory(title: title, in: ctx)
        if ctx.hasChanges { try ctx.save() }
    }

    func rename(from oldTitle: String, to newTitle: String) throws {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", oldTitle)
        req.fetchLimit = 1
        if let obj = try ctx.fetch(req).first {
            obj.title = newTitle
            if ctx.hasChanges { try ctx.save() }
        }
    }

    func delete(title: String) throws {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", title)
        if let obj = try ctx.fetch(req).first {
            ctx.delete(obj)
            if ctx.hasChanges { try ctx.save() }
        }
    }

    func renameCategory(oldTitle: String, newTitle: String) throws {
        try rename(from: oldTitle, to: newTitle)
    }

    func deleteCategory(title: String) throws {
        try delete(title: title)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
