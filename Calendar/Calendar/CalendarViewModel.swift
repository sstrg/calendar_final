import Foundation
import Combine
import SwiftData

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var modelContext: ModelContext?
    
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func load() async {
        guard let user = SessionManager.shared.user,
              let userId = user.id else { return }
        
        isLoading = true
        
        loadLocalEvents(for: userId)
        
        isLoading = false
    }
    
    private func loadLocalEvents(for userId: UUID) {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.eventDate)])
        
        do {
            let allEvents = try modelContext.fetch(descriptor)
            events = allEvents.filter { $0.userID == userId }
        } catch {
            errorMessage = "Failed to load events: \(error.localizedDescription)"
        }
    }
    
    func addEvent(title: String, date: Date, startTime: Date? = nil, notes: String? = nil) async {
        guard let user = SessionManager.shared.user,
              let userId = user.id else { return }
        
        let newEvent = Event(
            title: title,
            eventDate: date,
            startTime: startTime,
            userID: userId,
            notes: notes
        )
        
        if let modelContext = modelContext {
            modelContext.insert(newEvent)
            try? modelContext.save()
            loadLocalEvents(for: userId)
        }
    }
    
    func deleteEvent(_ event: Event) async {
        guard let userId = SessionManager.shared.user?.id else { return }
        
        if let modelContext = modelContext {
            modelContext.delete(event)
            try? modelContext.save()
            loadLocalEvents(for: userId)
        }
    }
}
