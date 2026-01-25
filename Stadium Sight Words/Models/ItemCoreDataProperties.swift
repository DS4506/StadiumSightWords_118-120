
import Foundation
import CoreData

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var dateAdded: Date?
}

extension Item: Identifiable { }
