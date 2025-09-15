//
//  TrackerStore.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import CoreData

protocol TrackerStoring {
    func create(_ tracker: Tracker, categoryTitle: String) throws
    func snapshot() throws -> [(tracker: Tracker, categoryTitle: String)]
    var onChange: (() -> Void)? { get set }
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
