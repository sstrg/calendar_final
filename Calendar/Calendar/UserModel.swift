import Foundation

struct UserModel: Codable {
    var id: UUID?
    var email: String
    var password: String?
    var username: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case password
        case username
    }
    
    init(id: UUID? = nil, email: String, password: String? = nil, username: String? = nil) {
        self.id = id
        self.email = email
        self.password = password
        self.username = username
    }
}
