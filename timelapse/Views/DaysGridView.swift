import SwiftUI

struct DaysGridView: View {
    let daysLeft: Int
    let totalDays: Int
    @ObservedObject var settings: DisplaySettings
    @EnvironmentObject var globalSettings: GlobalSettings
    @State private var selectedDate: Date? = nil
    @State private var tappedIndex: Int? = nil
    
    var daysCompleted: Int {
        totalDays - daysLeft
    }
    
    private func dateForIndex(_ index: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let startOfYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: today)))!
        return calendar.date(byAdding: .day, value: index, to: startOfYear)!
    }
    
    private func handleTap(index: Int, date: Date) {
        selectedDate = date
        tappedIndex = index
        
        // Reset the tapped index after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if tappedIndex == index {
                tappedIndex = nil
            }
        }
    }
    
    @ViewBuilder
    func gridItem(index: Int) -> some View {
        let isHighlighted = tappedIndex == index
        let color = index >= (totalDays - daysLeft) ? 
            (isHighlighted ? settings.displayColor : settings.displayColor.opacity(0.3)) : 
            (isHighlighted ? settings.displayColor : settings.displayColor)
        let date = dateForIndex(index)
        
        switch globalSettings.gridShape {
        case .circle:
            Circle()
                .fill(color)
                .onTapGesture {
                    handleTap(index: index, date: date)
                }
        case .square:
            Rectangle()
                .fill(color)
                .onTapGesture {
                    handleTap(index: index, date: date)
                }
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .onTapGesture {
                    handleTap(index: index, date: date)
                }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let containerPadding: CGFloat = 6
            let columns = 20
            let spacing: CGFloat = 8
            
            let availableWidth = geometry.size.width - (2 * containerPadding) - (spacing * CGFloat(columns - 1))
            let dotSize = availableWidth / CGFloat(columns)
            
            ZStack {
                LazyVGrid(columns: Array(repeating: .init(.fixed(dotSize)), count: columns), spacing: spacing) {
                    ForEach(0..<totalDays, id: \.self) { index in
                        gridItem(index: index)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(containerPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if let date = selectedDate, let index = tappedIndex {
                    GeometryReader { geo in
                        let dotPosition = CGPoint(
                            x: CGFloat(index % 20) * (dotSize + spacing) + dotSize/2 + containerPadding,
                            y: CGFloat(index / 20) * (dotSize + spacing) + dotSize/2 + containerPadding
                        )
                        
                        VStack {
                            Text(date, style: .date)
                                .font(.system(.caption))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(Color(white: 0.1).opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        }
                        .position(
                            x: dotPosition.x,
                            y: dotPosition.y - 20
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDate = nil
                        tappedIndex = nil
                    }
                    .transition(.opacity)
                }
            }
        }
        .frame(height: 260)
    }
}
