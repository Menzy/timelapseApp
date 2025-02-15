import SwiftUI

struct ContentView: View {
    @StateObject private var navigationState = NavigationStateManager.shared
    @StateObject private var eventStore = EventStore()
    @StateObject private var globalSettings = GlobalSettings()
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentDate = Date()
    @State private var selectedTab = 0
    @State private var yearTrackerSettings: DisplaySettings = DisplaySettings(backgroundStyle: .dark)
    
    private func settings(for event: Event) -> DisplaySettings {
        if event.title == String(currentYear) {
            return yearTrackerSettings
        }
        let settings = eventStore.displaySettings[event.id] ?? DisplaySettings(backgroundStyle: globalSettings.effectiveBackgroundStyle)
        settings.updateColor(for: globalSettings.effectiveBackgroundStyle)
        return settings
    }
    
    private func updateAllColors(for backgroundStyle: BackgroundStyle) {
        yearTrackerSettings.updateColor(for: backgroundStyle)
        for settings in eventStore.displaySettings.values {
            settings.updateColor(for: backgroundStyle)
        }
    }
    
    private func scheduleNextUpdate() {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())),
              let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + midnight.timeIntervalSince(Date())) {
            currentDate = Date()
            scheduleNextUpdate()
        }
    }
    
    var daysLeft: Int {
        let calendar = Calendar.current
        let today = currentDate
        let endOfYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: today) + 1))!
        return calendar.dateComponents([.day], from: today, to: endOfYear).day ?? 0
    }
    
    var currentYear: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    
    private var displayedEvents: [Event] {
        // Always put year tracker first, then other events
        let yearTracker = eventStore.events.first { $0.title == String(currentYear) }
        let otherEvents = eventStore.events.filter { $0.title != String(currentYear) }
        return [yearTracker].compactMap { $0 } + otherEvents
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let padding = screenWidth * 0.1
            
            ZStack {
                NoiseBackground(
                    darkColor: Color(white: 0.15),
                    lightColor: Color(white: 0.25)
                )
                .environmentObject(globalSettings)
                
                VStack {
                    Spacer()
                    TabView(selection: $selectedTab) {
                        ForEach(Array(displayedEvents.enumerated()), id: \.element.id) { index, event in
                            let progress = event.progressDetails()
                            let eventSettings = settings(for: event)
                            
                            TimeCard(
                                title: event.title,
                                settings: eventSettings,
                                eventStore: eventStore,
                                daysLeft: progress.daysLeft,
                                totalDays: progress.totalDays
                            )
                            .tag(index)
                            .padding(.horizontal, padding)
                            .environmentObject(globalSettings)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    PageControl(
                        numberOfPages: displayedEvents.count,
                        currentPage: $selectedTab
                    )
                    .frame(height: 20)
                    
                    Spacer()
                    NavigationBar()
                }
            }
            .onChange(of: globalSettings.backgroundStyle) { oldStyle, newStyle in
                updateAllColors(for: newStyle)
            }
            .onChange(of: colorScheme) { oldColorScheme, newColorScheme in
                globalSettings.updateSystemAppearance(newColorScheme == .dark)
            }
            .onAppear {
                currentDate = Date()
                scheduleNextUpdate()
                globalSettings.updateSystemAppearance(colorScheme == .dark)
            }
            .sheet(isPresented: $navigationState.showingCustomize) {
                if let event = displayedEvents[safe: selectedTab] {
                    CustomizeView(settings: settings(for: event))
                        .environmentObject(globalSettings)
                }
            }
            .sheet(isPresented: $navigationState.showingTrackEvent) {
                TrackEventView(eventStore: eventStore)
            }
            .sheet(isPresented: $navigationState.showingSettings) {
                Text("Settings View") // Placeholder for now
            }
            .onAppear {
                currentDate = Date()
                scheduleNextUpdate()
            }
        }
    }
}

// Add this extension to safely access array elements
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ContentView()
        .environmentObject(GlobalSettings()) // Provide global settings
}

