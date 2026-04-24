import SwiftUI
import SwiftData

@main
struct CalendarApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Event.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(container)
        }
    }
}

struct AppRootView: View {
    @State private var isLoggedIn = false
    @State private var isLoading = true
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                    Text("Loading...")
                        .padding()
                }
            } else if isLoggedIn {
                CalendarView()
            } else {
                LoginView(onLoginSuccess: {
                    isLoggedIn = true
                })
            }
        }
        .task {
            await checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() async {
        // Проверяем, есть ли сохраненный пользователь
        if SessionManager.shared.user != nil {
            // Пользователь уже вошел
            isLoggedIn = true
        } else {
            // Пользователь не вошел, показываем экран логина
            isLoggedIn = false
        }
        isLoading = false
    }
}
