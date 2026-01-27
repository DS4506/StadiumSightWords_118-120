
import Foundation
import CoreData

extension SessionSummary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionSummary> {
        NSFetchRequest<SessionSummary>(entityName: "SessionSummary")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var sport: String?
    @NSManaged public var score: Int64
    @NSManaged public var correctCount: Int64
    @NSManaged public var incorrectCount: Int64
    @NSManaged public var accuracyPercent: Int64
    @NSManaged public var bestStreak: Int64
    @NSManaged public var timestamp: Date?
}

extension SessionSummary: Identifiable { }
