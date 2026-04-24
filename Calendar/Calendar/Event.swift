import Foundation
import SwiftData

@Model
final class Event {
    var id: UUID
    var title: String
    var eventDate: Date
    var startTime: Date?
    var endTime: Date?
    var userID: UUID
    var createdAt: Date
    var notes: String?
    var isAllDay: Bool
    
    init(id: UUID = UUID(), title: String, eventDate: Date, startTime: Date? = nil, endTime: Date? = nil, userID: UUID, notes: String? = nil, isAllDay: Bool = false) {
        self.id = id
        self.title = title
        self.eventDate = eventDate
        self.startTime = startTime
        self.endTime = endTime
        self.userID = userID
        self.createdAt = Date()
        self.notes = notes
        self.isAllDay = isAllDay
    }
}
