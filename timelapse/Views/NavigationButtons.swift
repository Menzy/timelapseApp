import SwiftUI

struct NavigationButton: View {
    let iconName: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(Color(white: 0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                Text(label)
                    .font(.custom("Courier", size: 14))
                    .foregroundColor(.white)
            }
        }
    }
}

struct NavigationBar: View {
    @StateObject private var navigationState = NavigationStateManager.shared
    
    var body: some View {
        HStack {
            Spacer()
            
            NavigationButton(
                iconName: "slider.horizontal.3",
                label: "Customize"
            ) {
                navigationState.showingCustomize = true
            }
            
            Spacer()
            
            NavigationButton(
                iconName: "calendar.badge.plus",
                label: "Track"
            ) {
                navigationState.showingTrackEvent = true
            }
            
            Spacer()
            
            NavigationButton(
                iconName: "gearshape",
                label: "Settings"
            ) {
                navigationState.showingSettings = true
            }
            
            Spacer()
        }
        .padding(.bottom, 40)
    }
}
