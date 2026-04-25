import Foundation

class APIService {
    static let shared = APIService()
    

    let baseURL = "http://127.0.0.1:8080"

    func register(email: String, password: String, username: String? = nil) async throws -> UserModel {
        print("🔵 Register attempt for: \(email)")
        
        guard let url = URL(string: "\(baseURL)/register") else {
            throw NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "username": username ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("🔵 Request body: \(body)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("🟡 Response raw data: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "API", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("🟡 HTTP Status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(errorMessage)"])
            }
            
            do {
                let user = try JSONDecoder().decode(UserModel.self, from: data)
                print("🟢 Success: \(user.email)")
                return user
            } catch {
                print("🔴 Decoding error: \(error)")
                throw NSError(domain: "API", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse server response"])
            }
            
        } catch {
            print("🔴 Network error: \(error)")
            throw error
        }
    }
    
    func login(email: String, password: String) async throws -> UserModel {
        print("🔵 Login attempt for: \(email)")
        
        guard let url = URL(string: "\(baseURL)/login") else {
            throw NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let body = ["email": email, "password": password]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("🟡 Response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "API", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("🟡 Status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
            }
            
            let user = try JSONDecoder().decode(UserModel.self, from: data)
            print("🟢 Logged in: \(user.email)")
            return user
            
        } catch {
            print("🔴 Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Event Methods
    func fetchEvents(userID: UUID) async throws -> [EventModel] {
        let url = URL(string: "\(baseURL)/events/\(userID.uuidString)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([EventModel].self, from: data)
    }
    
    func createEvent(_ event: EventModel) async throws -> EventModel {
        let url = URL(string: "\(baseURL)/events")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = try JSONEncoder().encode(event)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: req)
        print("🟡 Create event response: \(String(data: data, encoding: .utf8) ?? "")")
        return try JSONDecoder().decode(EventModel.self, from: data)
    }
    

    func deleteEvent(eventId: UUID) async throws {
        let url = URL(string: "\(baseURL)/events/\(eventId.uuidString)")!
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete event"])
        }
        print("🟢 Event deleted: \(eventId)")
    }
    
    func updateEvent(_ event: EventModel) async throws -> EventModel {
        guard let eventId = event.id else {
            throw NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: "Event has no ID"])
        }
        
        let url = URL(string: "\(baseURL)/events/\(eventId.uuidString)")!
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.httpBody = try JSONEncoder().encode(event)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: req)
        print("🟢 Event updated: \(eventId)")
        return try JSONDecoder().decode(EventModel.self, from: data)
    }
}
