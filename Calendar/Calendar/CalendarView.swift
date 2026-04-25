import SwiftUI
import SwiftData

struct CalendarView: View {
    @StateObject private var vm = CalendarViewModel()
    @State private var showingAddEvent = false
    @State private var selectedDate = Date()
    @State private var showingLogoutAlert = false
    @State private var showingLoginScreen = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                if vm.isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                    Spacer()
                } else {
                    List {
                        ForEach(eventsForSelectedDate) { event in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.title)
                                    .font(.headline)
                                
                                if let startTime = event.startTime {
                                    Text("Time: \(startTime.formatted(date: .omitted, time: .shortened))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let notes = event.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let event = eventsForSelectedDate[index]
                                Task {
                                    await vm.deleteEvent(event)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Exit")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView { title, startTime, notes in
                    Task {
                        await vm.addEvent(
                            title: title,
                            date: selectedDate,
                            startTime: startTime,
                            notes: notes
                        )
                    }
                }
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .refreshable {
                await vm.load()
            }
            .fullScreenCover(isPresented: $showingLoginScreen) {
                LoginView(onLoginSuccess: {
                    showingLoginScreen = false
                    Task {
                        await vm.load()
                    }
                })
            }
        }
        .onAppear {
            vm.configure(with: modelContext)
            Task {
                await vm.load()
            }
        }
    }
    
    private var eventsForSelectedDate: [Event] {
        vm.events.filter { Calendar.current.isDate($0.eventDate, inSameDayAs: selectedDate) }
    }
    
    private func logout() {
        SessionManager.shared.user = nil
        
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
        
        showingLoginScreen = true
    }
}

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var startTime = Date()
    @State private var hasStartTime = false
    @State private var notes = ""
    
    let onSave: (String, Date?, String?) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    
                    Toggle("Add time", isOn: $hasStartTime)
                    
                    if hasStartTime {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, hasStartTime ? startTime : nil, notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
