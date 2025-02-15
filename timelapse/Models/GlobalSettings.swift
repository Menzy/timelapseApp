import SwiftUI

class GlobalSettings: ObservableObject {
    @Published var backgroundStyle: BackgroundStyle = .dark
    @Published var gridShape: GridShape = .circle
    @Published private var systemIsDark: Bool = false
    
    var effectiveBackgroundStyle: BackgroundStyle {
        if backgroundStyle == .device {
            return systemIsDark ? .dark : .light
        }
        return backgroundStyle
    }
    
    var invertedColor: Color {
        effectiveBackgroundStyle == .light ? Color.black : Color.white
    }
    
    var invertedSecondaryColor: Color {
        effectiveBackgroundStyle == .light ? Color.gray : Color(white: 0.5)
    }
    
    func updateSystemAppearance(_ isDark: Bool) {
        systemIsDark = isDark
        objectWillChange.send()
    }
}
