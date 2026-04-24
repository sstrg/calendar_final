import Combine
import Foundation

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var user: UserModel? {
        didSet {
            if let user = user, let userId = user.id {
                saveUserToUserDefaults(user)
            } else {
                clearUserDefaults()
            }
        }
    }
    
    private let userDefaultsKey = "loggedInUser"
    
    private init() {
        loadUserFromUserDefaults()
    }
    
    private func saveUserToUserDefaults(_ user: UserModel) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUserFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(UserModel.self, from: data) {
            self.user = user
        }
    }
    
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func logout() {
        user = nil
    }
    
    var isLoggedIn: Bool {
        user != nil
    }
}
