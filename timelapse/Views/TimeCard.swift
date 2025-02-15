import SwiftUI

struct TimeCard: View {
    let title: String
    @ObservedObject var settings: DisplaySettings
    @ObservedObject var eventStore: EventStore
    let daysLeft: Int
    let totalDays: Int
    @State private var showingDaysLeft = true
    @State private var showingEditSheet = false
    @EnvironmentObject var globalSettings: GlobalSettings // Use global settings

    var daysSpent: Int {
        totalDays - daysLeft
    }
    
    var percentageLeft: Double {
        (Double(daysLeft) / Double(totalDays)) * 100
    }
    
    var percentageSpent: Double {
        (Double(daysSpent) / Double(totalDays)) * 100
    }
    
    var daysText: String {
        let count = showingDaysLeft ? daysLeft : daysSpent
        let type = showingDaysLeft ? "left" : "in"
        let dayText = count == 1 ? "day" : "days"
        return "\(settings.showPercentage ? "" : "\(dayText) ")\(type)"
    }
    
    @ViewBuilder
    func timeDisplayView() -> some View {
        switch settings.style {
        case .grid:
            DaysGridView(daysLeft: daysLeft, totalDays: totalDays, settings: settings)
        case .circle:
            CircleDisplayView(daysLeft: daysLeft, totalDays: totalDays, settings: settings)
                .environmentObject(globalSettings) // Provide global settings
        case .progressBar:
            ProgressBarView(daysLeft: daysLeft, totalDays: totalDays, settings: settings)
                .environmentObject(globalSettings) // Provide global settings
        case .boldText:
            BoldTextView(daysLeft: daysLeft, showDaysLeft: showingDaysLeft, settings: settings)
                .environmentObject(globalSettings) // Provide global settings
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            timeDisplayView()
                .frame(height: 300)
                .padding(16)
                .onAppear {
                    print("TimeCard: Displaying time card with settings: \(settings)")
                }
            
            Divider()
                .background(globalSettings.invertedSecondaryColor)
            
            HStack {
                Text(title)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(globalSettings.invertedColor)
                Spacer()
                HStack(spacing: 4) {
                    if settings.showPercentage {
                        Text(String(format: "%.0f%%", showingDaysLeft ? percentageLeft : percentageSpent))
                            .font(.custom("Courier", size: 16))
                            .foregroundColor(globalSettings.invertedColor)
                    } else {
                        Text("\(showingDaysLeft ? daysLeft : daysSpent)")
                            .font(.custom("Courier", size: 16))
                            .foregroundColor(globalSettings.invertedColor)
                    }
                    AnimatedText(text: daysText)
                        .font(.custom("Courier", size: 16))
                        .foregroundColor(globalSettings.invertedSecondaryColor)
                }
                .onTapGesture {
                    withAnimation {
                        showingDaysLeft.toggle()
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(globalSettings.backgroundStyle == .light ? Color.white : Color(white: 0.2))
        )
        .sheet(isPresented: $showingEditSheet) {
            if let event = eventStore.events.first(where: { $0.title == title }) {
                EditEventView(event: event, eventStore: eventStore)
            }
        }
        .onTapGesture(count: 2) {
            if title != String(Calendar.current.component(.year, from: Date())) {
                showingEditSheet = true
            }
        }
    }
}
