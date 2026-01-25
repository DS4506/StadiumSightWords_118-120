
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // IMPORTANT:
        // This string MUST match your .xcdatamodeld filename (without extension).
        // Example: Stadium_Sight_Words.xcdatamodeld  ->  "Stadium_Sight_Words"
        let c = NSPersistentContainer(name: "Stadium_Sight_Words")

        if let desc = c.persistentStoreDescriptions.first {
            if inMemory {
                desc.url = URL(fileURLWithPath: "/dev/null")
            }

            // Allow lightweight migration
            desc.shouldMigrateStoreAutomatically = true
            desc.shouldInferMappingModelAutomatically = true
        }

        var didResetStore = false

        c.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {

                // If migration fails, nuke the store ONE time and recreate.
                if !didResetStore, let url = storeDescription.url {
                    didResetStore = true

                    do {
                        try c.persistentStoreCoordinator.destroyPersistentStore(
                            at: url,
                            ofType: storeDescription.type,
                            options: storeDescription.options
                        )

                        // Try again after destroying the incompatible store
                        c.loadPersistentStores { _, error2 in
                            if let error2 = error2 as NSError? {
                                fatalError("Core Data still failed after reset: \(error2), \(error2.userInfo)")
                            }
                        }

                        return
                    } catch {
                        fatalError("Failed to destroy persistent store: \(error.localizedDescription)")
                    }
                }

                // If it failed again after reset, crash with details
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }

        c.viewContext.automaticallyMergesChangesFromParent = true
        c.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        self.container = c
    }
}
