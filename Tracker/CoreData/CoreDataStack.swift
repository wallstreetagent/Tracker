//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

import CoreData

final class CoreDataStack {
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }

    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        if let d = container.persistentStoreDescriptions.first {
            d.shouldMigrateStoreAutomatically = true
            d.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error { assertionFailure("CoreData load error: \(error)") }
        }
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.undoManager = nil
        viewContext.shouldDeleteInaccessibleFaults = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        ctx.undoManager = nil
        return ctx
    }

    func saveViewContextIfNeeded() {
        let ctx = viewContext
        guard ctx.hasChanges else { return }
        do { try ctx.save() } catch { assertionFailure("save error: \(error)") }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        container.performBackgroundTask { ctx in
            do {
                try block(ctx)
                if ctx.hasChanges { try ctx.save() }
            } catch {
                assertionFailure("bg error: \(error)")
            }
        }
    }
}
