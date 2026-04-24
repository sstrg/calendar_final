import Foundation
import SwiftData

@MainActor
class TestDataManager {
    static let shared = TestDataManager()
    
    // Создание тестового пользователя в локальной базе данных
    func createTestUser(in modelContext: ModelContext) -> UserModel? {
        print("🔵 Creating test user...")
        
        // Проверяем, есть ли уже пользователи в сессии
        if SessionManager.shared.user != nil {
            print("🟡 User already logged in")
            return SessionManager.shared.user
        }
        
        // Тестовые данные
        let testEmail = "test@example.com"
        let testPassword = "123456"
        let testUsername = "Test User"
        
        // Создаем тестового пользователя
        let testUser = UserModel(
            id: UUID(),
            email: testEmail,
            password: testPassword,
            username: testUsername
        )
        
        // Сохраняем в сессию
        SessionManager.shared.user = testUser
        
        print("🟢 Test user created:")
        print("   📧 Email: \(testEmail)")
        print("   🔑 Password: \(testPassword)")
        print("   👤 Username: \(testUsername)")
        
        return testUser
    }
    
    // Создание тестовых событий
    func createTestEvents(in modelContext: ModelContext, for userId: UUID) {
        print("🔵 Creating test events...")
        
        let calendar = Calendar.current
        let today = Date()
        
        // Тестовые события
        let testEvents = [
            (
                title: "Team Meeting",
                date: calendar.date(byAdding: .day, value: 0, to: today)!,
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today),
                notes: "Discuss project progress"
            ),
            (
                title: "Lunch with Client",
                date: calendar.date(byAdding: .day, value: 1, to: today)!,
                startTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today),
                notes: "At Italian restaurant"
            ),
            (
                title: "Doctor Appointment",
                date: calendar.date(byAdding: .day, value: 2, to: today)!,
                startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today),
                notes: "Annual checkup"
            ),
            (
                title: "Submit Report",
                date: calendar.date(byAdding: .day, value: 3, to: today)!,
                startTime: nil,
                notes: "End of quarter report"
            ),
            (
                title: "Birthday Party",
                date: calendar.date(byAdding: .day, value: 5, to: today)!,
                startTime: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today),
                notes: "Bring gift"
            )
        ]
        
        for eventData in testEvents {
            let event = Event(
                id: UUID(),
                title: eventData.title,
                eventDate: eventData.date,
                startTime: eventData.startTime,
                endTime: nil,
                userID: userId,
                notes: eventData.notes,
                isAllDay: eventData.startTime == nil
            )
            modelContext.insert(event)
        }
        
        try? modelContext.save()
        print("🟢 Created \(testEvents.count) test events")
    }
    
    // Создание тестового пользователя на сервере
    func createTestUserOnServer() async throws -> UserModel {
        print("🔵 Creating test user on server...")
        
        let testEmail = "test_server@example.com"
        let testPassword = "123456"
        
        do {
            let user = try await APIService.shared.register(
                email: testEmail,
                password: testPassword,
                username: "Test Server User"
            )
            print("🟢 Test user created on server: \(user.email)")
            return user
        } catch {
            print("🔴 Failed to create test user on server: \(error)")
            throw error
        }
    }
    
    // Полная настройка тестовых данных
    func setupTestData(in modelContext: ModelContext) async {
        print("\n" + String(repeating: "=", count: 50))
        print("📱 SETTING UP TEST DATA")
        print(String(repeating: "=", count: 50))
        
        // 1. Создаем локального тестового пользователя
        guard let testUser = createTestUser(in: modelContext),
              let userId = testUser.id else {
            print("🔴 Failed to create test user")
            return
        }
        
        // 2. Создаем тестовые события
        createTestEvents(in: modelContext, for: userId)
        
        // 3. Пытаемся создать пользователя на сервере
        do {
            _ = try await createTestUserOnServer()
        } catch {
            print("⚠️ Server test user creation failed, but continuing with local data")
        }
        
        print("\n✅ Test data setup complete!")
        print("📧 Login with: test@example.com / 123456")
        print(String(repeating: "=", count: 50) + "\n")
    }
    
    // Быстрый вход с тестовым пользователем
    func quickLogin() -> UserModel? {
        let testUser = UserModel(
            id: UUID(),
            email: "test@example.com",
            password: "123456",
            username: "Test User"
        )
        SessionManager.shared.user = testUser
        return testUser
    }
}

