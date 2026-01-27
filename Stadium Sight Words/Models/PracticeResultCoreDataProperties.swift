
import Foundation
import CoreData

extension PracticeResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PracticeResult> {
        NSFetchRequest<PracticeResult>(entityName: "PracticeResult")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var sport: String?
    @NSManaged public var word: String?
    @NSManaged public var wasCorrect: Bool
    @NSManaged public var timestamp: Date?
}

extension PracticeResult: Identifiable { }
