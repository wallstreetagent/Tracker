//
//  StatisticsProvider.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/1/25.
//

import CoreData


final class StatisticsProviderCoreData: NSObject, StatisticsProviding {
    private let stack: CoreDataStack
    var onChange: (() -> Void)?

    private lazy var frc: NSFetchedResultsController<TrackerRecordCoreData> = {
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: stack.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    init(stack: CoreDataStack) {
        self.stack = stack
        super.init()
        _ = frc
    }

    func completedTotal() -> Int {
        frc.fetchedObjects?.count ?? 0
    }
}

extension StatisticsProviderCoreData: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
