//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/12/25.
//

// CoreDataStack.swift
import CoreData

final class CoreDataStack {
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        if let desc = container.persistentStoreDescriptions.first {
            desc.shouldMigrateStoreAutomatically = true
            desc.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error { assertionFailure("CoreData load error: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        ctx.undoManager = nil
        return ctx
    }

    func saveViewContextIfNeeded() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do { try ctx.save() } catch { assertionFailure("save error: \(error)") }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { ctx in
            block(ctx)
            if ctx.hasChanges {
                do { try ctx.save() } catch { assertionFailure("bg save error: \(error)") }
            }
        }
    }
}
