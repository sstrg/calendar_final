import Foundation

struct EventModel: Identifiable, Codable {
    var id: UUID?
    var title: String
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var userID: UUID

    enum CodingKeys: String, CodingKey {
        case id, title, date
        case startTime = "start_time"
        case endTime = "end_time"
        case userID = "user_id"
    }
}
