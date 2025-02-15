import SwiftUI

struct CircleDisplayView: View {
    let daysLeft: Int
    let totalDays: Int
    @ObservedObject var settings: DisplaySettings
    @EnvironmentObject var globalSettings: GlobalSettings
    
    var daysSpent: Int {
        totalDays - daysLeft
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(settings.displayColor.opacity(0.3), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: max(0.001, CGFloat(daysSpent) / CGFloat(totalDays)))
                .stroke(settings.displayColor, lineWidth: 20)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: daysSpent)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProgressBarView: View {
    let daysLeft: Int
    let totalDays: Int
    @ObservedObject var settings: DisplaySettings
    @EnvironmentObject var globalSettings: GlobalSettings
    
    var daysSpent: Int {
        totalDays - daysLeft
    }
    
    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(settings.displayColor.opacity(0.3))
                    
                    Rectangle()
                        .fill(settings.displayColor)
                        .frame(width: max(2, geometry.size.width * CGFloat(daysSpent) / CGFloat(totalDays)))
                }
            }
            .frame(height: 20)
            .cornerRadius(10)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct BoldTextView: View {
    let daysLeft: Int
    let showDaysLeft: Bool
    @ObservedObject var settings: DisplaySettings
    @EnvironmentObject var globalSettings: GlobalSettings
    
    var daysSpent: Int {
        365 - daysLeft
    }
    
    var body: some View {
        Text("\(showDaysLeft ? daysLeft : daysSpent)")
            .font(.system(size: 120, weight: .heavy, design: .rounded))
            .foregroundColor(settings.displayColor)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
