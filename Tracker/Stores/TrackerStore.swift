//
//  TrackerStore.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import CoreData

protocol TrackerStoring: AnyObject {
    var onChange: (() -> Void)? { get set }

    func snapshot() throws -> [(tracker: Tracker, categoryTitle: String)]
    func create(_ tracker: Tracker, categoryTitle: String) throws

    func update(id: UUID,
                name: String,
                schedule: Set<Weekday>,
                colorHex: String,
                emoji: String,
                categoryTitle: String) throws

    func delete(id: UUID) throws
    func togglePin(id: UUID, categoryStore: TrackerCategoryStoring) throws
}

final class TrackerStore: NSObject, TrackerStoring {
    private let stack: CoreDataStack
    private let categoryStore: TrackerCategoryStoring

    var onChange: (() -> Void)?

    private lazy var frc: NSFetchedResultsController<TrackerCoreData> = {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        let frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: stack.viewContext,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    init(stack: CoreDataStack, categoryStore: TrackerCategoryStoring) {
        self.stack = stack
        self.categoryStore = categoryStore
        super.init()
        _ = frc
    }

    func create(_ tracker: Tracker, categoryTitle: String) throws {
        stack.performBackgroundTask { ctx in
            let cat = try self.categoryStore.ensureCategory(title: categoryTitle, in: ctx)
            let obj = TrackerCoreData(context: ctx)
            obj.id = tracker.id
            obj.name = tracker.name
            obj.emoji = tracker.emoji
            obj.colorHex = tracker.colorHex
            obj.scheduleMask = Int16(WeekdayMask.make(from: tracker.schedule))
            obj.category = cat
        }
    }

    func snapshot() throws -> [(tracker: Tracker, categoryTitle: String)] {
        try frc.performFetch()
        let items = frc.fetchedObjects ?? []
        return items.map { cd in
            let t = Tracker(
                id: cd.id ?? UUID(),
                name: cd.name ?? "",
                colorHex: cd.colorHex ?? "#34C759",
                emoji: cd.emoji ?? "🙂",
                schedule: WeekdayMask.toSet(UInt16(cd.scheduleMask))
            )
            let title = cd.category?.title ?? "Без категории"
            return (t, title)
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}

extension TrackerStore {

    func update(id: UUID,
                name: String,
                schedule: Set<Weekday>,
                colorHex: String,
                emoji: String,
                categoryTitle: String) throws {

        try stack.performBackgroundTask { ctx in
         
            let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            req.fetchLimit = 1

            guard let obj = try ctx.fetch(req).first else { return }

        
            obj.name = name
            obj.emoji = emoji
            obj.colorHex = colorHex

            let mask = WeekdayMask.make(from: schedule)
            obj.scheduleMask = Int16(mask)

            let cat = try self.categoryStore.ensureCategory(title: categoryTitle, in: ctx)
            obj.category = cat

      
        }
    }
}

import CoreData

extension TrackerStore {
    func delete(id: UUID) throws {
        try stack.performBackgroundTask { ctx in
            let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            req.fetchLimit = 1
            if let obj = try ctx.fetch(req).first {
                let recReq: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                recReq.predicate = NSPredicate(format: "tracker == %@", obj)
                for r in try ctx.fetch(recReq) { ctx.delete(r) }
                ctx.delete(obj)
                if ctx.hasChanges { try ctx.save() }
            }
        }
    }

    func togglePin(id: UUID, categoryStore: TrackerCategoryStoring) throws {
        try stack.performBackgroundTask { ctx in
            let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            req.fetchLimit = 1
            guard let obj = try ctx.fetch(req).first else { return }

            let pinned = try categoryStore.ensureCategory(title: "Закреплённые", in: ctx)
            if obj.category?.title == "Закреплённые" {
                let normal = try categoryStore.ensureCategory(title: "Без категории", in: ctx)
                obj.category = normal
            } else {
                obj.category = pinned
            }
            if ctx.hasChanges { try ctx.save() }
        }
    }
}
