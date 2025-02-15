import Foundation

class EventStore: ObservableObject {
    @Published var events: [Event] = []
    private let eventsKey = "savedEvents"
    @Published var displaySettings: [UUID: DisplaySettings] = [:]
    private let displaySettingsKey = "savedDisplaySettings"
    
    init() {
        loadEvents()
        loadDisplaySettings()
        addDefaultYearTrackerIfNeeded()
    }
    
    func saveEvent(_ event: Event) {
        events.append(event)
        // Initialize display settings when saving a new event
        let newSettings = DisplaySettings()
        displaySettings[event.id] = newSettings
        saveEvents()
        saveDisplaySettings()
    }
    
    func updateEvent(id: UUID, title: String, targetDate: Date) {
        if let index = events.firstIndex(where: { $0.id == id }) {
            events[index] = Event(title: title, targetDate: targetDate, creationDate: events[index].creationDate)
            saveEvents()
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([Event].self, from: data) {
            events = decoded
        }
    }
    
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: eventsKey)
        }
    }
    
    private func loadDisplaySettings() {
        if let data = UserDefaults.standard.data(forKey: displaySettingsKey),
           let decoded = try? JSONDecoder().decode([UUID: DisplaySettings].self, from: data) {
            displaySettings = decoded
        }
    }
    
    private func saveDisplaySettings() {
        if let encoded = try? JSONEncoder().encode(displaySettings) {
            UserDefaults.standard.set(encoded, forKey: displaySettingsKey)
        }
    }
    
    private func addDefaultYearTrackerIfNeeded() {
        let defaultEvent = Event.defaultYearTracker()
        if !events.contains(where: { $0.title == defaultEvent.title }) {
            events.insert(defaultEvent, at: 0)
            saveEvents()
        }
    }
}
